## Required Software
* **Web Server**
    * [ColdFusion Developer Edition](https://www.adobe.com/products/coldfusion/download-trial/try.html)
    * [XAMPP (Apache, PHP, MySQL, phpMyAdmin)](https://www.apachefriends.org/index.html)

* **Development**
    * [Node](https://nodejs.org/en/)
    * [Python 3.6](https://www.python.org/downloads/)
    * [Sublime Text 3](https://www.sublimetext.com/3)

* **Source Control**
    * [Git](https://git-scm.com/downloads)
    * [Source Tree](https://www.sourcetreeapp.com/)

## Installation

1. First install the source control software. Install Git and make sure to check the option that adds it to the PATH environment variable. After Git has installed, install Source Tree.

2. Install Node and make sure to check the option that adds it to the PATH environment variable. If it doesn't add it for you, you will have to do it manually ([see here]()).

3. Install Python 3.6 and make sure to check the option that adds it to the PATH environment variable. If it doesn't add it for you, you will have to do it manually ([see here]()).

4. Install Sublime Text 3. It will be a trial version with **no** limited time.

5. Now install XAMPP. It will ask you which modules you would like to install, just check them all and continue.

6. Once XAMPP is installed, open it up and try to start the Apache and MySQL service. If you encounter errors ask for help.

7. Now that XAMPP is installed and Apache is running (**make sure you keep Apache running**) you can install ColdFusion. Click through the wizard until you get to the web server connector section. It should give you the option to add a connector. If so, select Apache and point the configuration directory to `C:\xampp\apache\conf`. Then point the binary path to `C:\xampp\apache\bin\httpd.exe`. Ignore any ambiguous errors and continue through the wizard until ColdFusion has been installed.

8. Open `C:\xampp\apache\conf\mod_jk.conf` and comment the line that starts with `JkShmFile` by putting a `#` at the start of the line. Like the following:

```
# JkShmFile "C:\ColdFusion2016\config\wsconfig\1\jk_shm"
```

9. Open up command prompt and `cd` to your desired project directory. This is where the source code will be kept for you to code and for the web server to serve the files from. Documents is usually fine.

```bat
cd /D "C:\Users\james\Documents"
```

Now run the following commands. This will clone all three repo's from GitHub that you need to develop EPOS, Admin and the MVC framework.

```bat
git clone https://github.com/small-stone-group/cf-framework.git
git clone https://github.com/small-stone-group/sle-admin.git
git clone https://github.com/small-stone-group/sle-epos.git
```

Now open up the `hosts` file in `C:\Windows\System32\drivers\etc` and add the following lines to the bottom.

```
127.0.0.1   sle-admin.lan
127.0.0.1   dev.sle-admin.lan
127.0.0.1   sle-epos.lan
127.0.0.1   dev.sle-epos.lan
```

10. Open `C:\xampp\apache\conf\extra\httpd-vhosts.conf` and add the following text to it - replacing `{ path_to.. }` with the path you cloned the repo's to, such as `C:/Users/james/Documents/GitHub/sle-admin`.

```
<VirtualHost *:80>
    DocumentRoot "{ path_to_sle_admin }"
    ServerName dev.sle-admin.lan
    ServerAlias *.sle-admin.lan
    <Directory "{ path_to_sle_admin }">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>

<VirtualHost *:80>
    DocumentRoot "{ path_to_sle_epos }"
    ServerName dev.sle-epos.lan
    ServerAlias *.sle-epos.lan
    <Directory "{ path_to_sle_epos }">
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
```

11. In your web browser visit [http://dev.sle-admin.lan](http://dev.sle-admin.lan). If it comes up with a ColdFusion error then that's good. If it doesn't show anything or shows a generic HTTP error then ask for help.
