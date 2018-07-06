###
#    Copyright 2015-2018 ppy Pty. Ltd.
#
#    This file is part of osu!web. osu!web is distributed with the hope of
#    attracting more community contributions to the core ecosystem of osu!.
#
#    osu!web is free software: you can redistribute it and/or modify
#    it under the terms of the Affero GNU General Public License version 3
#    as published by the Free Software Foundation.
#
#    osu!web is distributed WITHOUT ANY WARRANTY; without even the implied
#    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with osu!web.  If not, see <http://www.gnu.org/licenses/>.
###

{button, div, h1, p, span} = ReactDOMFactories
el = React.createElement

changelogBuildGrouping = (builds) ->
  _.groupBy builds, (build) ->
    # Assumes created_at an iso8601 datetime string and removes the time portion.
    # Example: 2018-07-06T05:43:21+00:00
    build.created_at.substr(0, 10)


class ChangelogIndex.Main extends React.PureComponent
  constructor: (props) ->
    super props

    builds = props.data.builds
    hasMore = builds.length == props.data.search.limit

    @state =
      # remove one so there's at least one more to be loaded
      builds: osu.jsonClone(if hasMore then builds[..-2] else builds)
      hasMore: hasMore
      loading: false


  componentDidMount: =>
    changelogChartLoader.initialize()
    $.subscribe 'changelog-index:showMore.changelogIndex', @showMore


  componentWillUnmount: =>
    $.unsubscribe '.changelogIndex'


  render: =>
    div null,
      div className: 'header-bg header-bg--changelog',
        div className: 'header-bg__overlay'

      div className: 'osu-page osu-page--changelog',
        div className: 'osu-page__header',
          @renderHeaderTitle()
          @renderHeaderTabs()

        el ChangelogHeaderBuilds, latestBuilds: @props.latestBuilds

        div className: 'js-changelog-chart'

        div className: 'builds',
          for own date, builds of changelogBuildGrouping(@state.builds)
            div
              key: date
              className: 'builds__group',
              div className: 'builds__date', moment(date).format('LL')

              for build in builds
                div
                  key: build.id
                  className: 'builds__item'
                  el Build, build: build

        el ShowMoreLink,
          event: 'changelog-index:showMore'
          hasMore: @state.hasMore
          loading: @state.loading
          modifiers: ['changelog-index']


  renderHeaderTabs: =>
    div className: 'page-mode-v2 page-mode-v2--changelog',
      span
        className: 'page-mode-v2__link page-mode-v2__link--active'
        osu.trans 'changelog.index.title.info'


  renderHeaderTitle: =>
    div className: 'osu-page-header-v3 osu-page-header-v3--changelog',
      div className: 'osu-page-header-v3__title js-nav2--header-title',
        div className: 'osu-page-header-v3__title-icon',
          div className: 'osu-page-header-v3__icon'
        h1
          className: 'osu-page-header-v3__title-text'
          dangerouslySetInnerHTML:
            __html: osu.trans 'changelog.index.title._',
              info: "<span class='osu-page-header-v3__title-highlight'>#{osu.trans('changelog.index.title.info')}</span>"


  showMore: (e) =>
    return if !@state.hasMore

    search = osu.jsonClone @props.data.search
    search.max_id = _.last(@state.builds).id - 1
    @setState loading: true

    $.get laroute.route('changelog.index'), search
    .done (data) =>
      @setState
        builds: @state.builds.concat(data.builds[..-2])
        hasMore: data.search.limit == data.builds.length
    .always =>
      @setState loading: false
