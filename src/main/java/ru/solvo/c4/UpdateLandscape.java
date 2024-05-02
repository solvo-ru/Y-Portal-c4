package ru.solvo.c4;

import com.structurizr.Workspace;
import com.structurizr.api.WorkspaceApiClient;
import com.structurizr.api.WorkspaceMetadata;
import com.structurizr.view.SystemLandscapeView;

import java.io.File;
import java.util.List;

public class UpdateLandscape extends AbstractRun {

    public static void main(String[] args) throws Exception {

        List<WorkspaceMetadata> workspaces = createAdminApiClient().getWorkspaces();
        SYSTEM_LANDSCAPE_WORKSPACE_METADATA = workspaces.stream().filter(workspaceMetadata -> workspaceMetadata.getId() == 4).toList().getFirst();
//        Workspace landscapeWorkspace = workspaceApiClient.getWorkspace(4);
        Workspace landscapeWorkspace =enrichSystemLandscape(new File("src/main/resources/solvo-landscape.dsl"));
        SystemLandscapeView view = landscapeWorkspace.getViews().createSystemLandscapeView("solvo-products", "Экосистема продуктов Solvo");
        view.addAllElements();
        WorkspaceApiClient workspaceApiClient = createWorkspaceApiClient(SYSTEM_LANDSCAPE_WORKSPACE_METADATA);
        workspaceApiClient.putWorkspace(4, landscapeWorkspace);
    }

}