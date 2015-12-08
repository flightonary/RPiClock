$(window).on('pageshow', () ->
    $('span[data-link]').click( (event) ->
        event.preventDefault()
        event.stopPropagation()
        location.href = $(this).data('link')
        return false
    )
)