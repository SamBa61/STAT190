library(reticulate)
install_python(version = "3.11.0")
virtualenv_create("my-python", python_version = "3.11.0")

use_virtualenv("my-python", required = TRUE)
virtualenv_install(envname = "my-python", "requests", ignore_installed = FALSE, pip_options= character())
virtualenv_install(envname = "my-python", "csv", ignore_installed = FALSE, pip_options= character())
virtualenv_install(envname = "my-python", "bs4", ignore_installed = FALSE, pip_options= character())
