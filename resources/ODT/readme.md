# Office Deployment Tool (ODT)

This folder contains any files, folders, apps, scripts, etc., as necessary resources to properly utilize the Office Deployment Tool (ODT) when installing Microsoft Office.

# Resources and References

- [https://config.office.com/](https://config.office.com/) - Create your own custom XML configuration file online.

# Getting Started
> **[ IMPORTANT ]**  
> This is basic information and should not serve as a "Knowledge Base," or any sort of Official Documentation for that matter, for ODT.

- **Step 1:** First, create a folder somewhere on your computer to hold the required file(s), like, `C:\ODT`.
- **Step 2:** Download the `setup.exe` file from this repo to the directory you created in the previous step, like, `C:\ODT\setup.exe`
- **Step 3:** Either download one of the `.XML` configuration files from this repo or create your own, then place it in that same folder like so: `C:\ODT\MyOfficeConfig.xml`
- **Step 4:** Open Command Prompt (CMD) and navigate to the folder containing your files. For example, `cd C:\ODT`
- **Step 5:** Use one of the following two options:
  - **Download**
    - **Summary:** Downloads the installation files to the `C:\ODT` folder to be used later as an "Offline Installer"
    - **Example:** `setup.exe /download MyOfficeConfig.xml`
  - **Configure**
    - **Summary:** Downloads and installs Microsoft Office based on the specified XML file.
    - **Example:** `setup.exe /configure MyOfficeConfig.xml`
 
 Done!
