import com.structurizr.Workspace

(workspace as Workspace).model.softwareSystems.each {
    addTags(it,"system")
    it.containers.each {
        addTags(it, "container")
        it.components.each { addTags(it, "component") }
    }
}


static def addTags(parent, suffix) {
    def cats = ['External', 'Tool', 'Pillar', 'Product', 'Addon']
    def stype = (parent.tagsAsSet as List).intersect(cats)
    stype.each{
        parent.addTags("${it} [${suffix}]")
    }
}