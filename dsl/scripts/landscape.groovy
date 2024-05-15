import com.structurizr.api.AdminApiClient
import com.structurizr.api.WorkspaceApiClient
import groovy.transform.Field

@Field static final STRUCTURIZR_ONPREMISES_URL = 'https://structurizr.moarse.ru'
@Field static final ADMIN_API_KEY_PLAINTEXT = 'CozyPlace'


def workspaces = getWorkspaces([2, 5, 6])
workspaces.each { subWorkspace ->
    def softwareSystem = subWorkspace.model.softwareSystems.find { !it.containers.isEmpty() }
    if (softwareSystem) {
        findElementByKey(workspace, getElementKey(softwareSystem))
                .setUrl("{workspace:${subWorkspace.id}}/diagrams")
    }
}
def view = workspace.views.createSystemLandscapeView("solvo-products", "Экосистема продуктов Solvo");
view.addAllElements();

static List getWorkspaces(List workspaceIds) {
    def adminApiClient = new AdminApiClient("${STRUCTURIZR_ONPREMISES_URL}/api", '', ADMIN_API_KEY_PLAINTEXT)
    def workspaces = adminApiClient.workspaces.findAll { it.id in workspaceIds }
    return workspaces.collect {
        def workspaceApiClient = new WorkspaceApiClient("${STRUCTURIZR_ONPREMISES_URL}/api", it.apiKey, it.apiSecret)
        workspaceApiClient.workspaceArchiveLocation = null
        workspaceApiClient.getWorkspace(it.id)
    }
}

static findElementByKey(def workspace, String key) {
    workspace.model.elements.find { getElementKey(it) == key }
}

static String getElementKey(def element) {
    element.properties['structurizr.dsl.identifier']
}


