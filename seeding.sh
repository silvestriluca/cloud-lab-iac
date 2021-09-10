read -p "This script will start a lab-infrastructure from scratch. Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Creating lab..."
    cp state-location/state-local.tf backend.tf
    terraform init
    echo "PLAN phase..."
    terraform plan
    read -p "Plan generted. Do you want to proceed? " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        echo "APPLY phase..."
        terraform apply
        echo "APPLY phase...Done"
        echo "Creating lab...Done"
    else
        echo "Aborted."
    fi
else
    echo "Aborted."
fi