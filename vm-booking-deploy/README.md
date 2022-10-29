This terraform project creates resources for remote backend.

For testing purposes, run:

```
AWS_PROFILE="bc" terraform init
AWS_PROFILE="bc" terraform plan -var-file="testing.tfvars" -target=module.api
AWS_PROFILE="bc" terraform apply -var-file="testing.tfvars" -target=module.api

```

Run only specific module:
```
AWS_PROFILE="bc" terraform plan -var-file="testing.tfvars" -target=module.vpc
AWS_PROFILE="bc" terraform apply -var-file="testing.tfvars" -target=module.vpc
```

to delete resources, run:

```
AWS_PROFILE="bc" terraform destroy -var-file="testing.tfvars" -target=module.api
```

