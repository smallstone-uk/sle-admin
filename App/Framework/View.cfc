component
{
    public any function init(required string name, struct args = structNew())
    {
        this.name = name;
        this.args = args;
        this.file = getFile(name);
        this.content = fileRead(this.file);
        this.uniqueName = lCase(createUUID());
        this.tempFile = "#expandPath('/')#Views\temp\#this.uniqueName#.cfm";
        fileWrite(this.tempFile, this.content);

        saveContent variable = "viewContent" {
            for (arg in this.args) {
                setVariable(arg, this.args[arg]);
            }

            include "..\..\Views\temp\#this.uniqueName#.cfm";
        }

        writeOutput(viewContent);
        fileDelete(this.tempFile);

        return this;
    }

    private string function getFile(required string name)
    {
        this.paths = [];

        if (findNoCase(".", name) > 0) {
            this.paths = listToArray(name, ".");
        } else if (findNoCase("/", name) > 0) {
            this.paths = listToArray(name, "/");
        } else if (findNoCase("\", name) > 0) {
            this.paths = listToArray(name, "\");
        } else {
            this.paths = [name];
        }

        return "#expandPath('/')#Views\#arrayToList(this.paths, '\')#.cfm";
    }
}
