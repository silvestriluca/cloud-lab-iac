read -p "This script will restore REMOTE state. Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # Restore remote
    echo "Restoring remote state..."
    mkdir private > /dev/null 2>&1
    mkdir private/config > /dev/null 2>&1
    echo "Retrieving remote state settings from AWS..."
    aws ssm get-parameter --name "/baseline/default/tf-backend-config" --with-decryption | jq -r .Parameter.Value > private/config/backend.cfg
    echo "Done"
    echo "Setting up remote state..."
    cp state-location/state-remote.tf backend.tf
    terraform init -backend-config=private/config/backend.cfg
    echo "Setting up remote state... Done"
    echo "Restoring remote state... Done"
else
    echo "Aborted."
fi