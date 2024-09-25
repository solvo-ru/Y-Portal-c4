import com.structurizr.Workspace
import com.structurizr.api.AdminApiClient
import com.structurizr.api.WorkspaceApiClient
import groovy.transform.Field
import com.structurizr.configuration.WorkspaceScope

@Field static final String STRUCTURIZR_ONPREMISES_URL = 'http://structurizr.solvo.ru'
@Field static final String ADMIN_API_KEY_PLAINTEXT = 'CozyPlace-36'
@Field Workspace workspace

/**
*   Find all existing System's workspaces and map their url's to the corresponding landscape's elements 
*   
**/

def LandscapeWorkspace = workspace
def SoftwareSystemWorkspaces = getWorkspaces()

SoftwareSystemWorkspaces.each { subWorkspace ->
    def softwareSystemFromSubWorkspace = subWorkspace.model.softwareSystems.find { !it.containers.isEmpty() }
    if (softwareSystemFromSubWorkspace) {
        LandscapeWorkspace.model.elements.find{
             getElementKey(it) == softwareSystemFromSubWorkspace.properties['structurizr.dsl.identifier'] 
        }.setUrl("{workspace:${subWorkspace.id}}/diagrams")

    }
}

def view = LandscapeWorkspace.views.createSystemLandscapeView("solvo-products", "Экосистема продуктов Solvo");
view.addAllElements();

static List getWorkspaces() {
    def adminApiClient = new AdminApiClient("${STRUCTURIZR_ONPREMISES_URL}/api", '', ADMIN_API_KEY_PLAINTEXT)

    def workspaces = adminApiClient.workspaces.collect {
        def workspaceApiClient = new WorkspaceApiClient("${STRUCTURIZR_ONPREMISES_URL}/api", it.apiKey, it.apiSecret)
        workspaceApiClient.workspaceArchiveLocation = null
        workspaceApiClient.getWorkspace(it.id)
    }
    return workspaces.findAll{it.configuration.scope==WorkspaceScope.SoftwareSystem }
}

static String getElementKey(def element) {
    element.properties['structurizr.dsl.identifier']
}


