### Configuration

You need to edit `config.rb` with your `VPC_ID` and `SUBNET_ID` where you want your VM to be spawned, it's recommended to use your default subnet so that your VM will have already internet access.

### Commands:

Here is a list of commands to setup the infrastructure for this project:

#### Setup

Sets up the prerequisites

    rake setup

#### Plan

    rake

#### Apply

    rake apply

#### Destroy

    rake destroy
