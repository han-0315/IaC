# Terraform 으로 AWS EKS 생성하는 CI/CD 파이프라인 예제

프로젝트에 있는 Terraform 코드를 바탕으로 EKS를 생성하는 CI/CD 파이프라인 예제입니다.

- **K8S** : EKS, eksctl과 같은 툴 없이 직접 Terraform으로 구축
- **CNI** : VPC-CNI
- **CSI** : EBS-CSI