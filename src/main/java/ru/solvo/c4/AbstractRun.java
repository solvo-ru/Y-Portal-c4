package ru.solvo.c4;

import com.structurizr.Workspace;
import com.structurizr.api.AdminApiClient;
import com.structurizr.api.WorkspaceApiClient;
import com.structurizr.api.WorkspaceMetadata;
import com.structurizr.configuration.WorkspaceScope;
import com.structurizr.dsl.DslUtils;
import com.structurizr.dsl.StructurizrDslParser;
import com.structurizr.model.*;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.List;
import java.util.regex.Pattern;

class AbstractRun {
    protected static final int LANDSCAPE_WORKSPACE_ID = 4;

    protected static String STRUCTURIZR_ONPREMISES_URL = "https://structurizr.moarse.ru";
    protected static final String ADMIN_API_KEY_PLAINTEXT = "CozyPlace";
    protected static final String ADMIN_API_KEY_BCRYPT = "$2a$10$V6PN618FLott/WqaUDlTfewtPzVVZBSg9J90ueoBr71LR9ldFPeOm";

    protected static WorkspaceMetadata SYSTEM_LANDSCAPE_WORKSPACE_METADATA;
    protected static WorkspaceMetadata CLOUD_WORKSPACE_METADATA;

    protected static AdminApiClient createAdminApiClient() {
        return new AdminApiClient(STRUCTURIZR_ONPREMISES_URL + "/api", "", ADMIN_API_KEY_PLAINTEXT);
    }

    protected static WorkspaceApiClient createWorkspaceApiClient(WorkspaceMetadata workspaceMetadata) {
        WorkspaceApiClient workspaceApiClient = new WorkspaceApiClient(STRUCTURIZR_ONPREMISES_URL + "/api", workspaceMetadata.getApiKey(), workspaceMetadata.getApiSecret());
        workspaceApiClient.setWorkspaceArchiveLocation(null); // this prevents the local file system from being cluttered with JSON files

        return workspaceApiClient;
    }

    protected static Workspace enrichSystemLandscape(File landscapeWorkspaceDsl) throws Exception {
        StructurizrDslParser parser = new StructurizrDslParser();
        parser.parse(landscapeWorkspaceDsl);
        Workspace landscapeWorkspace = parser.getWorkspace();
        enrichSystemLandscape(landscapeWorkspace);
        if (landscapeWorkspace != null) {return landscapeWorkspace;}
        //Переделать

        String oldDsl = DslUtils.getDsl(landscapeWorkspace);
        StringBuilder computedRelationships = new StringBuilder("\n//###\n");
        for(Relationship relationship: landscapeWorkspace.getModel().getRelationships()){
            computedRelationships.append(getDslRelationship(relationship));
        }
        String replacementRgx="(?sm)(//###.+)?\\s*}\\s+views\\s*\\{";
        String newDsl = oldDsl.replaceFirst(replacementRgx, computedRelationships.append("\n}\n views {").toString());
        try (FileWriter writer = new FileWriter(landscapeWorkspaceDsl)) {
            writer.write(newDsl);
            System.out.println("String value written to file successfully.");
        } catch (IOException e) {
            System.out.println("An error occurred while writing to the file.");
            e.printStackTrace();
        }
        return landscapeWorkspace;
    }
    protected static void enrichSystemLandscape(Workspace systemLandscapeWorkspace) throws Exception {
        List<WorkspaceMetadata> workspaces = createAdminApiClient().getWorkspaces().stream().filter(workspaceMetadata -> !List.of(1, 3, 4).contains(workspaceMetadata.getId())).toList();
        for (WorkspaceMetadata workspaceMetadata : workspaces) {
            WorkspaceApiClient workspaceApiClient = createWorkspaceApiClient(workspaceMetadata);
            workspaceApiClient.setWorkspaceArchiveLocation(null);
            Workspace workspace = workspaceApiClient.getWorkspace(workspaceMetadata.getId());
//            String viewType = "SystemContext";
//            if (workspace.getViews().getSystemContextViews().isEmpty()){
//                viewType = "Container";
//                if(workspace.getViews().getContainerViews().isEmpty()){
//                    viewType = "Component";
//                }
//            }
            if (workspace.getConfiguration().getScope() == WorkspaceScope.SoftwareSystem) {
                SoftwareSystem softwareSystem = findScopedSoftwareSystem(workspace);
                if (softwareSystem != null) {
                    findElementByKey(systemLandscapeWorkspace,getElementKey((softwareSystem)))
                      .setUrl("{workspace:" + workspaceMetadata.getId() + "}/diagrams");
                }
                //findAndCloneRelationships(workspace, systemLandscapeWorkspace);
            }
        }

        // create a system landscape view
/*//        SystemLandscapeView view = systemLandscapeWorkspace.getViews().createSystemLandscapeView("Landscape", "An automatically generated system landscape view.");
//        view.addAllElements();*/
//        view.enableAutomaticLayout();
//
//        // and push the landscape workspace to the on-premises installation
//        WorkspaceApiClient workspaceApiClient = createWorkspaceApiClient(SYSTEM_LANDSCAPE_WORKSPACE_METADATA);
//        workspaceApiClient.putWorkspace(SYSTEM_LANDSCAPE_WORKSPACE_METADATA.getId(), systemLandscapeWorkspace);
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

    private static Element findElementByKey(Workspace workspace, String key) {
        for (Element element : workspace.getModel().getElements()) {
            if (getElementKey(element).equals(key)) {
                return element;
            }
        }
        return null;
    }
    private static String getElementKey(Element element) {
        return element.getProperties().get("structurizr.dsl.identifier");
    }

    protected static String getDslRelationship (Relationship relationship) {
        StringBuilder dslString = new StringBuilder();

        String description = "";
        if (relationship.getDescription()!=null) {
            description = relationship.getDescription();
        }
        String technology = "";
        if (relationship.getTechnology()!=null) {
            technology = relationship.getTechnology();
        }
        String tags = relationship.getTags().replace("Relationship,","");
        dslString.append(getElementKey(relationship.getSource())).append(" -> ")
                .append(getElementKey(relationship.getDestination())).append(" \"")
                .append(description).append("\" \"").append(technology)
                .append("\" \"").append(tags).append("\"\n");

        return dslString.toString();
    }

}