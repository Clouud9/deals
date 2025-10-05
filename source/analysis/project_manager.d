module analysis.project_manager;

// May add new ones later
enum ProjectType {
    Dub,
    XMake,
    Make,
    Now,
    None
}

abstract class ProjectManager {
    ProjectType type;
    string root;
    string[] import_paths;
    string[] source_paths;
    string[] stdlib_paths;
    abstract void reconfigure();
    public abstract void fillProjectPaths();
    public abstract void fillStdlibPaths();
    public abstract string projectRoot();
}

final class DubManager : ProjectManager {
    this(string given_root) {
        this.type = ProjectType.Dub;
        this.root = given_root; // Just assume that the root given by the client is correct for now 

        this.reconfigure();
    }

    override void reconfigure() {
        import_paths.length = 0;
        source_paths.length = 0;
        stdlib_paths.length = 0;

        this.fillProjectPaths();
        this.fillStdlibPaths();
    }

    override void fillProjectPaths() {
        import dub.dub;
        import dub.package_;
        import dub.project;
        import dub.dependency;
        import dub.internal.vibecompat.inet.path;
        import dub.packagemanager;
        import dmd.frontend;

        auto dub_ = new Dub(this.root);
        dub_.loadPackage();

        Project project = dub_.project();
        Package rootPackage = project.rootPackage();
        const PackageRecipe recipie = rootPackage.rawRecipe();
        auto dependencyList = recipie.dependencies;
        PackageManager pm = dub_.packageManager();

        foreach (string depName, Dependency dep; dependencyList) {
            dep.visit!(
                (VersionRange vr) {
                Package pk = pm.getBestPackage(PackageName(depName), vr);
                NativePath path = pk.path();
                /* 
                    * TODO: Add null check later, and may want to consider using NativePath data structure anyways, 
                    *  to differentiate between local and absolute paths
                    */
                this.import_paths ~= path.toNativeString();
            },
                (NativePath np) { this.import_paths ~= np.toNativeString(); },// I do not expect a repository URL to work right now, I will handle it later
                (Repository rp) {
                this.import_paths ~= rp.remote();
                assert(0, "Repository Support will come later");
            }
            );
        }

        const string[][string] sourcePaths = recipie.sourcePaths;
        foreach (const string[] paths; sourcePaths) {
            foreach (string path; paths) {
                this.source_paths ~= (this.root ~ "\\" ~ path);
            }
        }
    }

    override void fillStdlibPaths() {
        import dmd.frontend;

        initDMD();
        auto stdlibPaths = findImportPaths();
        foreach (path; stdlibPaths)
            this.stdlib_paths ~= path;

        deinitializeDMD();
    }

    // TODO: Implement Later
    override string projectRoot() {
        return "Implement Later";
    }
}
