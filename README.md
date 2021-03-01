# mysql-shell

`mysql-shell` is a docker container version of MySQL shell.


1. Build the docker image with:
    ```bash
    docker build --tag mysql-shell:latest .
    ```
### Connect directly a `MySQL` instance using IP:
1. Run tester:
    ```bash
    docker run -it --rm --name mysqlsh mysql-shell mysqlsh
    ```