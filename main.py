from cbc_sdk import CBCloudAPI

# Carbon Black Cloud credentials
cbc_org_url="https://defense-eu.conferdeploy.net"
cbc_org_token="MZP4JEJ6ZJDLPZ93MHCBWTH2/7QGA4YDD""
cbc_org_key="7QGA4YDD"

# Initialize CBCloudAPI object
cbc_api = CBCloudAPI(url=cbc_org_url, token=cbc_api_id, ssl_verify=False)

# Authenticate against CBC
cbc_api.authenticate()

# Fetch all deregistered devices
deregistered_devices = cbc_api.select(Device).where("status:Deregistered").sort_by("last_contact desc")

# Iterate through deregistered devices
for device in deregistered_devices:
    # Check if device is a VDI clone based on hostname or other identifying information
    if device.hostname.startswith("VDI"):
        print(f"Deleting VDI clone device: {device.device_id}")
        # Delete the VDI clone device
        device.delete()
    else:
        print(f"Skipping non-VDI clone device: {device.device_id}")
