package com.scichart.accessebility.helpers

abstract class NodeBase protected constructor(private val id: Int) : INode {
    override fun getId(): Int {
        return id
    }
}
