read -p "This script will restore LOCAL state. Are you sure? " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Restoring remote state..."
    echo "NOT IMPLEMENTED"
    # cp state-location/state-local.tf backend.tf
    # terraform init -migrate-state
    echo "Restoring remote state...Done"
else
    echo "Aborted."
fi