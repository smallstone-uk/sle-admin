component
{
    this.name = "SLE_Production";
    this.clientStorage = "kcc_cf_sle";
    this.clientManagement = false;
    this.sessionManagement = true;
    this.applicationTimeout = createTimeSpan(2,0,0,0);
    this.sessionTimeout = createTimeSpan(0,0,60,0);
    this.setClientCookies = true;

    // Boot Framework
    new App.Framework.Application.Boot();

    public boolean function onApplicationStart()
    {
        application.mvc = {
            'datasource' = 'kcc_sle_production',
            'migrationDatasource' = 'mvc_sle',
           // does not work  'dataDirectory' = (getDirectoryFromPath(getCurrentTemplatePath()) & "..\data\"),
			'dataDirectory' = 'D:\HostingSpaces\SLE-Production\sle-admin.co.uk\data\',
            'baseDirectory' = getDirectoryFromPath(getCurrentTemplatePath()),
            'migrationTableName' = 'migrations'
        };

        // Load the config into application
        var config = (fileExists(getBaseDir('app.json'))) ? deserializeJSON(fileRead(getBaseDir('app.json'))) : {};
        for (key in config) { application[key] = config[key]; }

        application.site.start = now();
        application.site.basedir = getBaseDir();
        application.site.fileDir = getBaseDir('source');
        application.site.normal = getUrl();
        application.site.secure = getUrl();
        //application.site.dir_data = getDataDir();
		application.site.dir_data = "D:\HostingSpaces\SLE-Production\sle-admin.co.uk\data\";
        application.site.dir_invoices = "D:\HostingSpaces\SLE-Production\sle-admin.co.uk\data\invoices\";
        application.site.dir_logs = "D:\HostingSpaces\SLE-Production\sle-admin.co.uk\data\logs\";
       // application.site.dir_logs = getDataDir('logs');
        application.site.url_data = getUrl('data');
        application.site.url_invoices = getUrl('data/invoices');

        application.site.debug = false;
        application.site.showdumps = false;

        include "appSite.cfm";

        return true;
    }

    public void function onRequestStart()
    {
        for (dir in ['logs/epos', 'epos', 'epos/misc', 'epos/receipts']) {
            if (!directoryExists(getDataDir(dir))) {
                directoryCreate(getDataDir(dir));
            }
        }
        
        if (structKeyExists(url, 'restart')) {
            onApplicationStart();
            writeDumpToFile(application);
        }

        if (structKeyExists(form, 'options')) {
            application.site.debug = structKeyExists(form, 'debug');
            application.site.showdumps = structKeyExists(form, 'showdumps');
        }

        request.building = {};
        request.building.start = now();
        request.oldLocale = setLocale("English (UK)");
    }

    public any function onSessionStart()
    {
        session.started = now();
        session.currDate = "";
        session.user = {};
        session.user.id = 0;
        session.user.loggedIn = false;
        session.user.firstname = "";
        session.user.lastname = "";
        session.user.eposLevel = 6;
        session.epos_frame = {};
        session.epos_frame.mode = "reg";
    }

    public any function onRequest(required string thePage)
    {
		if (len(application.site.error) IS 0) {
			include thePage;
			include "settings.cfm";
		} else {
			include "error.cfm";
		}
    }
}
