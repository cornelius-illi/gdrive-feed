# -*- coding: utf-8 -*-
# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify a custom renderer if needed.
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call.
  # navigation.renderer = Your::Custom::Renderer

  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  # navigation.selected_class = 'your_selected_class'

  # Specify the class that will be applied to the current leaf of
  # active navigation items. Defaults to 'simple-navigation-active-leaf'
  # navigation.active_leaf_class = 'your_active_leaf_class'

  # Item keys are normally added to index items as id.
  # This setting turns that off
  # navigation.autogenerate_item_ids = false

  # You can override the default logic that is used to autogenerate the item ids.
  # To do this, define a Proc which takes the key of the current item as argument.
  # The example below would add a prefix to each key.
  # navigation.id_generator = Proc.new {|key| "my-prefix-#{key}"}

  # If you need to add custom html around item names, you can define a proc that will be called with the name you pass in to the navigation.
  # The example below shows how to wrap items spans.
  # navigation.name_generator = Proc.new {|name| "<span>#{name}</span>"}

  # The auto highlight feature is turned on by default.
  # This turns it off globally (for the whole plugin)
  # navigation.auto_highlight = false

  # Define the primary navigation
  navigation.items do |primary|
    primary.dom_class = 'side-nav'

    primary.item :recources_label, 'Configuration', :class => 'heading strong'
    primary.item :monitored_resources, '<span class="fi-plus"></span> Create New Resource', monitored_resources_path, :highlights_on => /monitored_resources/
    primary.item :monitored_periods, '<span class="fi-calendar"></span> Define Periods', monitored_periods_path
    primary.item :period_groups, '<span class="fi-results"></span> Relate Periods', period_groups_path
    primary.item :calculate_threshold, '<span class="fi-graph-pie"></span> Calculate Threshold', show_threshold_path
    primary.item :divider1, '', :class => 'divider'
    primary.item :recources_label1, 'Monitored Resources', :class => 'heading strong'
    if user_signed_in? && !current_user.monitored_resources.blank?
      current_user.monitored_resources.each_with_index do |monitored_resource,j|
        primary.item "mr-#{j}", '<span class="fi-folder"></span> ' + monitored_resource.try(:title), monitored_resource_path(monitored_resource)
      end
    end
    primary.item :divider2, '', :class => 'divider'
    primary.item :recources_labe2l, 'Reports', :class => 'heading strong'
    if user_signed_in? && !current_user.monitored_resources.blank?
      current_user.monitored_resources.each_with_index do |monitored_resource,k|
        primary.item "mr-r-#{k}", '<span class="fi-graph-bar"></span> ' + monitored_resource.try(:title), monitored_resource_reports_path(monitored_resource)
      end
    end
    primary.item :metareport, '<span class="fi-graph-trend"></span> Meta-Reports', reports_metareport_path

    # you can also specify a css id or class to attach to this particular level
    # works for all levels of the menu
    # primary.dom_id = 'menu-id'
    # primary.dom_class = 'menu-class'

    # You can turn off auto highlighting for a specific level
    # primary.auto_highlight = false

  end
end