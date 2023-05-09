## EKS 원클릭 배포
해당 자료는 EKS 스터디 당시 CloudNet 팀에서 제공한 자료입니다.

아래의 소스코드에 자신에 맞는 값을 추가하여 배포합니다. 
`
aws cloudformation deploy --template-file eks.yaml --stack-name myeks --parameter-overrides KeyName=[] SgIngressSshCidr=$(curl -s ipinfo.io/ip)/32  MyIamUserAccessKeyID=AKI... MyIamUserSecretAccessKey='CVN...' ClusterBaseName=myeks --region ap-northeast-2
`