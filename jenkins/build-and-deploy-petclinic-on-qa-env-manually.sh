PATH="$PATH:/usr/local/bin:$HOME/bin" # Hoca burayi almamasina ragmen jenkins deki job hata vermedi, artik buna ihtiyac olmyor. Bu komutun islevi ne?
APP_NAME="petclinic"
APP_REPO_NAME="clarusway-repo/petclinic-app-qa" #ecr repoya verdigimiz isim
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION="us-east-1"
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com" # cinamik ol. account id ve region cekiliyor
echo 'Packaging the App into Jars with Maven'
. ./jenkins/package-with-maven-container.sh
echo 'Preparing QA Tags for Docker Images' # tag leri olusturma adimi
. ./jenkins/prepare-tags-ecr-for-qa-docker-images.sh
echo 'Building App QA Images'
. ./jenkins/build-qa-docker-images-for-ecr.sh
echo "Pushing App QA Images to ECR Repo" #ecr a push luyor image lari
. ./jenkins/push-qa-docker-images-to-ecr.sh
echo 'Deploying App on Kubernetes Cluster'
. ./jenkins/deploy_app_on_qa_environment.sh
echo 'Deleting all local images'
docker image prune -af # jenkins makinenin temiz tutulmasi lazim, firma icin önemli