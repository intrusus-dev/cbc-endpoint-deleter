<h1 align="center">
    <img src="https://avatars.githubusercontent.com/u/2071378?s=200&v=4" alt="Script Icon" width="200">
    <br>
    Automate Endpoint and VDI Clone Deletion in VMware Carbon Black Cloud
</h1>

<p align="center">
    <em>A collection of scripts for managing VDI clones and deregistered endpoints in VMware Carbon Black Cloud</em>
</p>

<p align="center">
    <a href="LICENSE">
        <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT">
    </a>
</p>

## Overview

This repository contains two PowerShell scripts for managing VDI clones and deregistered endpoints in the VMware Carbon Black Cloud environment. The scripts are designed to simplify the process of identifying and deleting specific types of devices based on predefined criteria.

### Script 1: VDI Clone Deletion Script

- Purpose: Deletes VDI clones that meet specific criteria.
- Function: Searches for VDI clones matching the specified criteria and deletes them.
- Script File: [vdi-clone-deleter.ps1](vdi-clone-deleter.ps1)

#### Criteria for Device deletion

To identify VDI clones for deletion, the following criteria are used:

- `status`: ["DEREGISTERED"]
- `deployment_type`: ["VDI"]
- `golden_device_status`: ["NOT_GOLDEN_DEVICE"]
- `deregistered_time`: More than 1h ago.

You can modify these criteria in the script to match your specific requirements. Open the `vdi-clone-deleter.ps1` script file and locate the section where the request body is constructed. You can update the values in the `criteria` object to modify the criteria as needed.
Corresponding criteria can be found in the official [API documentation](https://developer.carbonblack.com/reference/carbon-black-cloud/platform/latest/devices-api/).

### Script 2: Deregistered Endpoint Deletion Script

- Purpose: Deletes deregistered endpoints that meet specific criteria.
- Function: Searches for deregistered endpoints matching the specified criteria and deletes them.
- Script File: [deregistered-endpoint-deleter.ps1](deregistered-endpoint-deleter.ps1)

#### Criteria for Device deletion
To identify deregistered endpoints for deletion, the following criteria are used:

- `status`: ["DEREGISTERED"]
- `unregistered_time`: More than 5 minutes ago

You can modify these criteria in the script to match your specific requirements. Open the `deregistered-endpoint-deleter.ps1` script file and locate the section where the request body is constructed. You can update the values in the `criteria` object to modify the criteria as needed.
Corresponding criteria can be found in the official [API documentation](https://developer.carbonblack.com/reference/carbon-black-cloud/platform/latest/devices-api/).

## Requirements

- PowerShell 5.1 or later
- API credentials for VMware Carbon Black Cloud

### How to set the correct API Access Level and get the API Key

To create the correct API Access Level, follow these steps:

1. Go to **SETTINGS** > **API Access**.
2. Click on the **Access Levels** tab on the top of the API page.
3. Click on the orange **Add Access Levels** button on the top right.
4. In the opened modal window, name the access level "Devices - Delete" and provide a description of your choice.
5. Set the following permissions:

   - Category: Device -> Permission: Deregistered -> DELETE
   - Category: Device -> Permission: General information -> READ

6. Click on **Save**.
7. Go to the **API Keys** tab on the top of the API page.
8. Click on the orange **Add API Key** button and enter a name in the opened modal window.
9. Select **Access Level Type** as "Custom" and choose **Devices - Delete** for Custom Access Level.
10. Click on **Save**.
11. Copy the API credentials. Close the credentials window and copy the **ORG KEY** from the top of the API page.

Make sure to replace `your_api_id`, `your_api_secret`, `your_org_url`, and `your_org_key` in the `auth.env` file (see below, "Getting Started") with the actual API credentials and organization details you obtained from the API Access page.

Once you have completed these steps, you will have the necessary API access level and credentials to authenticate and interact with the VMware Carbon Black Cloud API in the provided scripts.


## Getting Started

1. Clone the repository: `git clone https://github.com/yourusername/your-repo.git`
2. Set up the `auth.env` file: 
   - Create a new file named `auth.env` in the repository's root directory.
   - Open the `auth.env` file in a text editor.
   - Add the following environment variables to the file:
     - `API_ID=your_api_id`
     - `API_SECRET=your_api_secret`
     - `ORG_URL=https://your_org_url`
     - `ORG_KEY=your_org_key`
   - Replace `your_api_id`, `your_api_secret`, `your_org_url`, and `your_org_key` with your actual API credentials and organization details.
   - The https://your_org_url is the url you are accessing Carbon Black Cloud with, e.g. https://defense-eu.conferdeploy.net or https://defense-prod05.conferdeploy.net.
   - Save the `auth.env` file.

## Usage

1. Open a PowerShell terminal or command prompt.
2. Navigate to the repository's directory.
3. Run the desired script:
   - For VDI clone deletion: `.\vdi-clone-deleter.ps1`
   - For deregistered endpoint deletion: `.\deregistered-endpoint-deleter.ps1`

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Disclaimer
Use of the script in any environment, including both production and testing environments, is at your own risk. The script has been tested in my own environment, but it may contain errors or bugs. I make no warranties or guarantees regarding the functionality, accuracy, or reliability of the script. 

Before deploying the script in a production environment, it is strongly recommended to perform thorough testing with a small group of devices to ensure its proper functionality and compatibility with your specific setup.

I shall not be held liable for any damages, losses, or issues arising from the use of the script. By using the script, you acknowledge and accept the risks involved and agree to release me from any liability related to its use.

Please exercise caution and perform adequate testing and validation before deploying the script in any critical or production environment.

---

<p align="center">
    <em>Powered by VMware Carbon Black</em>
</p>
