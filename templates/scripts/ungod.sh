# Add every CodeBuild role that you want to strip from admin power here
#aws iam detach-role-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --role-name *CODEBUILD_ROLE_WORKPSPACE_1_NAME_HERE*
#aws iam detach-role-policy --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --role-name *CODEBUILD_ROLE_WORKPSPACE_2_NAME_HERE*
echo "God mode OFF (Codebuild role)"
