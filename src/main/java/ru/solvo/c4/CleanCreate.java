package ru.solvo.c4;

import com.structurizr.Workspace;
import com.structurizr.api.WorkspaceApiClient;
import com.structurizr.api.WorkspaceMetadata;
import com.structurizr.dsl.StructurizrDslParser;

import java.io.File;

public class CleanCreate extends AbstractRun {

    public static void main(String[] args) throws Exception {
        SYSTEM_LANDSCAPE_WORKSPACE_METADATA = createAdminApiClient().createWorkspace();
        loadWorkspaces();
        generateSystemLandscapeWorkspace();

//        System.out.println("Structurizr on-premises installation: " + STRUCTURIZR_ONPREMISES_URL);
//        System.out.println("System landscape workspace: " + STRUCTURIZR_ONPREMISES_URL + "/share/1/diagrams#Landscape");
//
//        try {
//            Runtime.getRuntime().exec("open " + STRUCTURIZR_ONPREMISES_URL + "/share/1/diagrams#Landscape");
//        } catch (IOException e) {
//            // ignore
//        }
    }

    private static void loadWorkspaces() throws Exception {
        File rootFolder = new File("src/main/resources/systems");
        File[] workspaceFolders = rootFolder.listFiles(File::isDirectory);
        assert workspaceFolders != null;
        for (File workspaceFolder : workspaceFolders) {
            File workspaceFile = new File(workspaceFolder.getPath()+"/workspace.dsl");
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

    private static void generateSystemLandscapeWorkspace() throws Exception {
        StructurizrDslParser parser = new StructurizrDslParser();
        parser.parse(new File("src/main/resources/solvo-landscape.dsl"));

        Workspace systemLandscapeWorkspace = parser.getWorkspace();
        systemLandscapeWorkspace.setName("Landscape");
        enrichSystemLandscape(systemLandscapeWorkspace);
    }

}