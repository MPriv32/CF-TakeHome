terraform {
  cloud {
    organization = "coalfiretakehome"

    workspaces {
      name = "coalfire"
    }
  }
}