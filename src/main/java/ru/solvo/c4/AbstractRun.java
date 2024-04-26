package ru.solvo.c4;

import com.structurizr.Workspace;
import com.structurizr.api.AdminApiClient;
import com.structurizr.api.WorkspaceApiClient;
import com.structurizr.api.WorkspaceMetadata;
import com.structurizr.configuration.WorkspaceScope;
import com.structurizr.model.*;
import com.structurizr.view.SystemLandscapeView;

import java.util.List;

class AbstractRun {

    protected static String STRUCTURIZR_ONPREMISES_URL = "https://structurizr.moarse.ru";
    protected static final String ADMIN_API_KEY_PLAINTEXT = "CozyPlace";
    protected static final String ADMIN_API_KEY_BCRYPT = "$2a$10$V6PN618FLott/WqaUDlTfewtPzVVZBSg9J90ueoBr71LR9ldFPeOm";

    protected static WorkspaceMetadata SYSTEM_LANDSCAPE_WORKSPACE_METADATA;

    protected static AdminApiClient createAdminApiClient() {
        return new AdminApiClient(STRUCTURIZR_ONPREMISES_URL + "/api","",  ADMIN_API_KEY_PLAINTEXT);
    }

    protected static WorkspaceApiClient createWorkspaceApiClient(WorkspaceMetadata workspaceMetadata) {
        WorkspaceApiClient workspaceApiClient = new WorkspaceApiClient(STRUCTURIZR_ONPREMISES_URL + "/api", workspaceMetadata.getApiKey(), workspaceMetadata.getApiSecret());
        workspaceApiClient.setWorkspaceArchiveLocation(null); // this prevents the local file system from being cluttered with JSON files

        return workspaceApiClient;
    }

    protected static void enrichSystemLandscape(Workspace systemLandscapeWorkspace) throws Exception {
        List<WorkspaceMetadata> workspaces = createAdminApiClient().getWorkspaces();
        for (WorkspaceMetadata workspaceMetadata : workspaces) {
            WorkspaceApiClient workspaceApiClient = createWorkspaceApiClient(workspaceMetadata);
            workspaceApiClient.setWorkspaceArchiveLocation(null);
            Workspace workspace = workspaceApiClient.getWorkspace(workspaceMetadata.getId());
            if (workspace.getConfiguration().getScope() == WorkspaceScope.SoftwareSystem) {
                SoftwareSystem softwareSystem = findScopedSoftwareSystem(workspace);
                if (softwareSystem != null) {
                    systemLandscapeWorkspace.getModel().getSoftwareSystemWithName(softwareSystem.getName()).setUrl("{workspace:" + workspaceMetadata.getId() + "}/diagrams#SystemContext");
                }

                findAndCloneRelationships(workspace, systemLandscapeWorkspace);
            }
        }

        // create a system landscape view
        SystemLandscapeView view = systemLandscapeWorkspace.getViews().createSystemLandscapeView("Landscape", "An automatically generated system landscape view.");
        view.addAllElements();
        view.enableAutomaticLayout();

        // and push the landscape workspace to the on-premises installation
        WorkspaceApiClient workspaceApiClient = createWorkspaceApiClient(SYSTEM_LANDSCAPE_WORKSPACE_METADATA);
        workspaceApiClient.putWorkspace(SYSTEM_LANDSCAPE_WORKSPACE_METADATA.getId(), systemLandscapeWorkspace);
    }

    protected static SoftwareSystem findScopedSoftwareSystem(Workspace workspace) {
        return workspace.getModel().getSoftwareSystems().stream().filter(ss -> !ss.getContainers().isEmpty()).findFirst().orElse(null);
    }

    protected static void findAndCloneRelationships(Workspace source, Workspace destination) {
        for (Relationship relationship : source.getModel().getRelationships()) {
            if (isPersonOrSoftwareSystem(relationship.getSource()) && isPersonOrSoftwareSystem(relationship.getDestination())) {
                cloneRelationshipIfItDoesNotExist(relationship, destination.getModel());
            }
        }
    }

    private static boolean isPersonOrSoftwareSystem(Element element) {
        return element instanceof Person || element instanceof SoftwareSystem;
    }

    private static void cloneRelationshipIfItDoesNotExist(Relationship relationship, Model model) {
        Relationship clonedRelationship = null;

        if (relationship.getSource() instanceof SoftwareSystem && relationship.getDestination() instanceof SoftwareSystem) {
            SoftwareSystem source = model.getSoftwareSystemWithName(relationship.getSource().getName());
            SoftwareSystem destination = model.getSoftwareSystemWithName(relationship.getDestination().getName());

            if (source != null && destination != null && !source.hasEfferentRelationshipWith(destination)) {
                clonedRelationship = source.uses(destination, relationship.getDescription());
            }
        } else if (relationship.getSource() instanceof Person && relationship.getDestination() instanceof SoftwareSystem) {
            Person source = model.getPersonWithName(relationship.getSource().getName());
            SoftwareSystem destination = model.getSoftwareSystemWithName(relationship.getDestination().getName());

            if (source != null && destination != null && !source.hasEfferentRelationshipWith(destination)) {
                clonedRelationship = source.uses(destination, relationship.getDescription());
            }
        } else if (relationship.getSource() instanceof SoftwareSystem && relationship.getDestination() instanceof Person) {
            SoftwareSystem source = model.getSoftwareSystemWithName(relationship.getSource().getName());
            Person destination = model.getPersonWithName(relationship.getDestination().getName());

            if (source != null && destination != null && !source.hasEfferentRelationshipWith(destination)) {
                clonedRelationship = source.delivers(destination, relationship.getDescription());
            }
        } else if (relationship.getSource() instanceof Person && relationship.getDestination() instanceof Person) {
            Person source = model.getPersonWithName(relationship.getSource().getName());
            Person destination = model.getPersonWithName(relationship.getDestination().getName());

            if (source != null && destination != null && !source.hasEfferentRelationshipWith(destination)) {
                clonedRelationship = source.delivers(destination, relationship.getDescription());
            }
        }

        if (clonedRelationship != null) {
            clonedRelationship.addTags(relationship.getTags());
        }
    }

}