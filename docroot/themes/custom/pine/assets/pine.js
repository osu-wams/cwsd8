! function($) {
    $(document).ready(function() {

        /* Search toggles */
        $("#_toggle-search").click(function(event) {
            event.preventDefault();
            if ($("#_search").is(":hidden")) {
                $("#_search").slideDown();
                $(".search__input").focus();

            } else {
                $("#_search").slideUp();
            }
        });

        $(".search__close").click(function() {
            $("#_search").slideUp();
        });

        /* Tab Menu Interactions */
        $('.tab-menu > a').click(function(event) {
            event.preventDefault();
            $('.tab-menu > a').removeClass('active');
            $(this).addClass('active');
            var story = $(this).attr("href");
            $(".story-wrapper > div").removeClass('active');
            $(story).addClass('active');
        });

        /* Toggle main menu */
        $('#_toggle-mobile-menu').click(function(e) {
            e.preventDefault();
            if ($("#block-homepage-main-menu").hasClass('hidden-md-down')) {
                $(".main-menu").addClass('nav-stacked');
                $('#block-homepage-main-menu').removeClass('hidden-md-down');
            } else {
                $(".main-menu").removeClass('nav-stacked');
                $('#block-homepage-main-menu').addClass('hidden-md-down');
            }
        });

    });
}(jQuery);
