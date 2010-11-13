# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  # Produces -> Thursday 25 May 2006 - 1:08 PM
  def fancy_date(date)
    h date.strftime("%A, %B %d, %Y")
  end
  
  def table(dom_id, rows, columns = nil)
    columns ||= rows.first.class.columns

    t = "<table id=\"#{dom_id}\" class=\"datatable\">"
    t << '<thead>'
    t << '<tr>'
    
    for column in columns
      unless column.name == 'id' or column.name == 'created_at' or column.name == 'updated_at'
        t << '<th>'
        t << column.name.capitalize.gsub(/_/, ' ')
        t << '</th>'
      end
    end
    
    t << '<th>Actions</th>'
    t << '</tr>'
    t << '</thead>'
    t << '<tbody>'
    
    for row in rows
      t << '<tr>'

      for column in columns
        unless column.name == 'id' or column.name == 'created_at' or column.name == 'updated_at'
          t << '<td>'
          t << row.attributes[column.name].to_s
          t << '</td>'
        end
      end

      t << '<td>'
      t << link_to('Delete', row, {:class => 'action', :confirm => 'Are you sure?', :method => :delete})
      t << '</td>'
      
      t << '</tr>'
    end
    
    t << '</tbody>'
    t << '</table>'

    t
  end
  
  def tableScripts(dom_id)
    t = '<script type="text/javascript" charset="utf-8">'
      t << 'var oTable;'
      t << 'var giRedraw = false;'
      
      # t << 'TableToolsInit.sSwfPath = "/swf/ZeroClipboard.swf";'
      t << '$(document).ready(function() {'
        t << "oTable = $('##{dom_id}').dataTable({"
          t << '"bJQueryUI": true,'
          t << '"bStateSave": true,'
          t << '"sPaginationType": "full_numbers",'
          t << '"sScrollX": "100%",'
          t << '"bSortClasses": false,'
          t << '"sDom": \'C<"clear"><"H"lfr>t<"F"ip>\','
        t << '});'
      
        # t << 'new FixedColumns( oTable );'

        # Highlight row and column on hover
        t << "$('td', oTable.fnGetNodes()).hover( function() {"
          t << "var iCol = $('td').index(this) % 5;"
          t << 'var nTrs = oTable.fnGetNodes();'
          t << "$('td:nth-child('+(iCol+1)+')', nTrs).addClass( 'highlighted' );"
        t << '}, function() {'
          t << "$('td.highlighted', oTable.fnGetNodes()).removeClass('highlighted');"
        t << '});'

        # Highlight row on click
        t << "$(\"##{dom_id} tr\").click(function(event) {"
          t << '$(oTable.fnSettings().aoData).each(function (){'
            t << "$(this.nTr).removeClass('row_selected');"
          t << '});'
          t << "$(event.target.parentNode).addClass('row_selected');"
        t << '});'
      
      t << '});'
    t << '</script>'
    
    t
  end
end