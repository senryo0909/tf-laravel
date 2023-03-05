<pre>
.
tf-laravel
    ├── README.md
    ├── envs
    │   ├── dev
    │   ├── prod
    │   └── stg
    │       ├── app
    │       │   └── foobar
    │       │       ├── backend.tf
    │       │       ├── data.tf
    │       │       ├── ecr.tf
    │       │       ├── ecs.tf
    │       │       ├── iam.tf
    │       │       ├── locals.tf
    │       │       ├── provider.tf -> ../../provider.tf
    │       │       ├── shared_locals.tf -> ../../shared_locals.tf
    │       │       └── variables.tf
    │       ├── cicd
    │       │   └── app_foobar
    │       │       ├── backend.tf
    │       │       ├── data.tf
    │       │       ├── ecspresso.tf
    │       │       ├── iam.tf
    │       │       ├── locals.tf
    │       │       ├── provider.tf -> ../../provider.tf
    │       │       └── shared_locals.tf -> ../../shared_locals.tf
    │       ├── db
    │       │   └── foobar
    │       │       ├── backend.tf
    │       │       ├── data.tf
    │       │       ├── db_instance.tf
    │       │       ├── db_option_group.tf
    │       │       ├── db_parameter_group.tf
    │       │       ├── iam.tf
    │       │       ├── locals.tf
    │       │       ├── provider.tf -> ../../provider.tf
    │       │       └── shared_locals.tf -> ../../shared_locals.tf
    │       ├── log
    │       │   ├── alb
    │       │   │   ├── backend.tf
    │       │   │   ├── data.tf
    │       │   │   ├── outputs.tf
    │       │   │   ├── provider.tf -> ../../provider.tf
    │       │   │   ├── s3.tf
    │       │   │   ├── shared_locals.tf -> ../../shared_locals.tf
    │       │   │   └── variables.tf
    │       │   ├── app_foobar
    │       │   │   ├── backend.tf
    │       │   │   ├── cloudwatch_log.tf
    │       │   │   ├── locals.tf
    │       │   │   ├── provider.tf -> ../../provider.tf
    │       │   │   └── shared_locals.tf -> ../../shared_locals.tf
    │       │   └── db_foobar
    │       │       ├── backend.tf
    │       │       ├── cloudwatch_log.tf
    │       │       ├── locals.tf
    │       │       ├── provider.tf -> ../../provider.tf
    │       │       └── shared_locals.tf -> ../../shared_locals.tf
    │       ├── network
    │       │   └── main
    │       │       ├── backend.tf
    │       │       ├── data.tf
    │       │       ├── db_subnet_group.tf
    │       │       ├── eip.tf
    │       │       ├── internet_gateway.tf
    │       │       ├── locals.tf
    │       │       ├── nat_gateway.tf
    │       │       ├── outputs.tf
    │       │       ├── provider.tf -> ../../provider.tf
    │       │       ├── route_table.tf
    │       │       ├── security_group.tf
    │       │       ├── shared_locals.tf -> ../../shared_locals.tf
    │       │       ├── subnet.tf
    │       │       ├── variables.tf
    │       │       └── vpc.tf
    │       ├── provider.tf
    │       ├── routing
    │       │   └── domain_name
    │       │       ├── acm.tf
    │       │       ├── alb.tf
    │       │       ├── backend.tf
    │       │       ├── data.tf
    │       │       ├── outputs.tf
    │       │       ├── provider.tf -> ../../provider.tf
    │       │       ├── route53.tf
    │       │       └── shared_locals.tf -> ../../shared_locals.tf
    │       └── shared_locals.tf
    └── modules 
        └── ecr
            ├── main.tf
            ├── outputs.tf
            └── variables.tf
</pre>

### タグについて
以下のtagsのvalueを変更すれば、明示指定しない場合、各サービスにタグがdefault設定される。

```sh
# provider.tf
default_tags { # 3.38以降は共通タグが付けられるようになった
      tags = {
        Env = "stg"
        System = "projectA"
      }
    }
```
### providerのtfState.stateへの読み込みのため、シンボリックリンク作成
```sh
$ cd stg or prod or dev/app/foobar
$ ln -fs ../../provider.tf provider.tf
```
### 環境全体で利用する変数をshared_locals.tfで管理し、各環境にシンボリックリンク作成
```sh
$ cd stg or prod or dev/app/foobar
$ ln -fs ../../shared_locals.tf shared_locals.tf
```
### 命名規則
#### terraform リソース名
- スネークケース
- 小文字・数字
- リソースの種類を名前に含めない ex) resource "aws_ecr_repository" "ecr_nginx"
- その種類のリソースだけを作成する場合は、thisをつける
#### AWS リソース名
- ケバブケース
- リソースの種類を名前に含めない
- {システム名}-{環境名}-{サービス名}のプレフィックスをつける

### コマンド
#### tfstateで管理しているリソース一覧確認
```sh
$ terraform state list
```
#### 引数で指定したリソースに対して、tfstate上での属性・値を確認
```sh
$ terraform state show aws_ecr_repository.nginx
```
#### 全体のリソース情報確認
```sh
$ terraform state pull > tmp.tfstate #多い時ようにファイル出力
```

### デプロイのロール
- assume roleを用いて、一時的に認可権限を付与する。デプロイに必要以上の権限を与えないことで、予期せず記載したデプロイ作業を行わせないように制限
- "Action": "sts:AssumeRole"で、ロールを引き受けるアクションを信頼ポリシーで定義している。これがあれば一時的に付与されることができる
- assumeRoleではaccessKey、SecretAccessKey、SessionTokenが一時的に付与される

### roleのおさらい
- https://dev.classmethod.jp/articles/iam-role-passrole-assumerole/
#### roleは３つのpolicyを定義できる
- permission boundary: 権限範囲
- 信頼ポリシー(resource base policy): エンティティ定義（個人かサービスか）
- identity base policy: 実行できるアクション
- session policy

### Todo メモ
deployする前に、ProjectA-stg-foobar-githubのIAMユーザーを作成する(Admin権限で)
作成したユーザーのarnをActionsのsecretに記載する
app/routing直下のdomain_nameには取得するドメイン名を入れたい
app/routing/domain_name/backend.tfのs3パスはドメイン名に変える
routingのapplyをする前にroute53でドメイン取得を行うこと
route53.tfのaws_route53_zoneの名前を取得したドメインに変更すること
outputs.tfは他のリソース作成時に必要なため、利用しているファイルより先にapplyする
albは作成時にvariable.tfのenable_albの値をtrueにする
NatGateway作成時には、variables.tfのenable_nat_gatewayをtrueにする。複数作成はsingle_nat_gatewayをfalse
ecsでサービス起動後(apply)後に、applicationリポジトリのecspressoディレクトリ以下のファイルに対して、tfstateから引っ張る値を編集する
- service_definition: ecs-service-def.json
- task_definition: ecs-task-def.json
RDS立ち上げ後はpasswordをコンソールから変更しておく
RDS作成後は、RDSに対する接続のパスワードをパラメータストアに格納し、phpコンテナから取得できるようにするために、以下のステップを踏む
- parameterの作成
```sh
aws ssm put-parameter --name "/projectA/stg/foobar/DB_PASSWORD --type "SecureString" --value "パスワード"
```
- ecspressoのecs-task-def.jsonのsecretsの設定

RDSのSGと同じSGをecsにも付与するために、ecs-service-dev.jsonも修正する リスト10-18
### パラメータストアに関して
laravelのアプリで非公開にしたい環境変数を扱う
tfでハードコーディングしたくないので、作成時にはダミーを登録し、作成後に、management consoleで値を再登録する
ignore_changesでapply時に上書きしないようにする
-　手順 1
```sh

$ make up
$ docker-compose exec app php artisan key:generate --show

```
- 手順 2
management consoleでパラメータ作成
パラメータ名は/アプリ名/環境名/foobar/APP_KEY
タイプは「安全な文字列」、KMSキーソースは現在のアカウント、KMSキーIDは「alias/aws/ssm」
値にAPP_KEYの値を貼り付ける

### ecs
- task-roleで運用中のタスクがAWS内外のサービスにAPI通信を制御する
- 起動時は、以下の条件が満たされていることに注意
- ALB: targetグループはHTTPSリスナーに紐づいている
- NatGateway: ecr cloudwatch パラメータストアにアクセスするために必要
- ECRにイメージが登録されている
- ECS ExecにはSession Managerを端末にインストールし、以下を実行
```sh
$ aws ecs execute-command --cluster projectA-stg-foobar --container nginx --interactive --command "/bin/sh" --task タスクID
```

### ecspresso.tfについて
- ecspressoはtfstateを参照できるが、一つだけの制約があるため、tfのリポジトリのenvs/stg/cicd/app_foobar/ecspresso.tfで集約を行いこれを使用する。
- ecsの起動後は、task-defenitionの値をtfstateから引っ張れるようになるので、定義ないに代入する

### migrationに関して 10.12
- ecspresso registerで新しいリビジョンのタスク定義を登録
- ecspresso run --latest-task-definitionで左真のタスク定義を用いてマイグレのみ行うタスク起動**実行後に自動停止する
- ecspresso deploy --latest-task-definitionで登録をせず最新のタスク定義でアプリのタスクをローリングアップデートする