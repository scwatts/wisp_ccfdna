import nextflow.Channel


class WorkflowMain {

  public static groupByMeta(... channels) {
    def r = channels
    // Set position; required to use non-blocking .mix operator
    // NOTE(SW): operating on native list object containing channels
    def i = 0
    r = r
      .collect { ch ->
        def ii = i
        def d = ch.map { data ->
          def meta = data[0]
          def values = data[1..-1]
          return [meta, [position: ii, values: values]]
        }
        i++
        return d
      }

    r = Channel.empty().mix(*r)

    r = r
      .groupTuple(size: channels.size())
      .map { data ->
        def meta = data[0]
        def values_map = data[1]

        def values_list = values_map
          .sort(false) { it.position }
          .collect { it.values }
        return [meta, *values_list]
      }

    return r.map { it.flatten() }
  }

}
