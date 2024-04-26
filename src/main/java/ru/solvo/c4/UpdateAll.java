package ru.solvo.c4;

import com.structurizr.Workspace;
import com.structurizr.api.WorkspaceApiClient;
import com.structurizr.api.WorkspaceMetadata;
import com.structurizr.dsl.StructurizrDslParser;

import java.io.File;

public class UpdateAll extends AbstractRun {
    protected static final int LANDSCAPE_WORKSPACE_ID = 4;
    protected static final int CONDUCTOR_WORKSPACE_ID = 5;
    protected static final int CLOUD_WORKSPACE_ID = 5;

    public static void main(String[] args) throws Exception {
        SYSTEM_LANDSCAPE_WORKSPACE_METADATA = createAdminApiClient().createWorkspace();
        loadWorkspace(new File("src/main/resources/systems/conductor/workspace.dsl"));
        generateSystemLandscapeWorkspace();
    }

    private static void loadWorkspaces() throws Exception {
        File rootFolder = new File("src/main/resources/systems");
        File[] workspaceFolders = rootFolder.listFiles(File::isDirectory);
        assert workspaceFolders != null;
        for (File workspaceFolder : workspaceFolders) {
            File workspaceFile = new File(workspaceFolder.getPath()+"/workspace.dsl");
            loadWorkspace(workspaceFile);
        }
    }

    private static void generateSystemLandscapeWorkspace() throws Exception {
        StructurizrDslParser parser = new StructurizrDslParser();
        parser.parse(new File("src/main/resources/solvo-landscape.dsl"));

        Workspace systemLandscapeWorkspace = parser.getWorkspace();
        systemLandscapeWorkspace.setName("Landscape");
        enrichSystemLandscape(systemLandscapeWorkspace);
    }

    private static void loadWorkspace(File workspaceFile) throws Exception {
        if (workspaceFile.exists() && workspaceFile.isFile()) {
            WorkspaceMetadata workspaceMetadata = createAdminApiClient().createWorkspace();
            StructurizrDslParser parser = new StructurizrDslParser();
            parser.parse(workspaceFile);
            Workspace workspace = parser.getWorkspace();
            workspace.trim();
            WorkspaceApiClient workspaceApiClient = createWorkspaceApiClient(workspaceMetadata);
            workspaceApiClient.setWorkspaceArchiveLocation(null);
            workspaceApiClient.putWorkspace(workspaceMetadata.getId(), workspace);
        }
    }
}