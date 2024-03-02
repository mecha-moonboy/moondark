md_journal = {}
md_journal.modname = minetest.get_modpath("md_journal")

if minetest.get_modpath("md_herbs") then
    guideBooks.Common.register_guideBook("md_journal:liber_herba", { --modname is the name of your mod, itemname is whatever you want
	description_short="Liber Herba",                              -- The name of your book
	description_long="On herbs and their qualities, dispositions, and effects.",                 -- an optional field to give your book an extra description
	inventory_image="liber_herba.png",                    -- The image of the book when in the inventory
	wield_image="liber_herba.png",                  -- An optional image of the book when in the hand
	style={                                                -- a table of values that describe how your book looks
		cover={                                            --- The very first page of your book
			w=5,                                           ---- how wide should the cover be?
			h=8,                                           ---- how tall should the cover be?
			bg="liber_herba_cover.png",                        ---- the file name of an image to use for the cover
			next="next.png"                        ---- the filename of an image to use for the 'next page' button
		},
		page={                                             --- The generic page style
			w=10,                                          ---- How wide is the book? (2*cover width works best)
			h=8,                                           ---- How tall is the book? (usually same as cover height)
			bg="liber_herba_page.png",                           ---- the background image for the open book
			next="next.png",                       ---- the filename of an image to use for the 'next page' button
			prev="prev.png",                       ---- the filename of an image to use for the 'previous page' button
			start="start.png",                    ---- the filename of an image to use for the 'first page' button
			textcolor="darkgreen",                             ---- the general color of the text. Default is white. An exhaustive list can be found here => https://drafts.csswg.org/css-color/#named-colors
			label_textcolor="green"                     ---- the color of the text inside the clickable sections. Same as textcolor if not specified.
		},
		buttonGeneric="button.png",                --- A generic button image
	},
	pad_type=false,						-- When true, the book will only display text1 on each page
	droppable=false					        -- When false, it doesn't allow the book to be dropped. If not specified, it's true by default
})
end

guideBooks.Common.register_section(
	"md_journal:liber_herba",             -- The name of a registered book
	"thrumberry",                    -- The name to give the section, only string values supported
	{                               -- A list of preset values (you could also put page definitions here.)
		description="Thrumberry",    --- The display name of the section
		hidden=false,               --- Whether the section is visible in the main index (set to true to hide)
		master=false,               --- Whether this section leads to an index (set to true to create a new index under this section)
		slave=false,                --- Set to false to show in the main index, set to the name of another section to show in that index. cannot be used with master=true
		Pages={                		--- The pages to preload into the section (use only for certain instances when required)
			Index={}                ---- A special page used only by the 'Main' section that loads after the cover
		},
		locked=false                --- If this is true, only players with the meta field <bookItem>:<sectionName>:unlocked=="true" will be able to see this section
	}
)

guideBooks.Common.register_page(
	"md_journal:liber_herba",                                       -- The name of a registered book
	"thrumberry",                                              -- The name of a section in the book
	1,                                                        -- the page number (or name in the case of special pages such as Index)
	{                                                         -- content definition
		textcolor="darkpurple",                                      -- the color of the text. If specified, it overrides the general textcolor for this very page
		text1="foo bar",                                      --- the text to display on the first half of the page
		text2="lorem ipsum dolor sit amet",                   --- the text to display on the second half of the page
		extra="background[0,0;5,8;modname_image.png;false]"   --- A minetest formspec string used to add extra content to a page, such as an image
	}
)
-- minetest.register_on_generated(function(minp, maxp, blockseed)
--     -- do things when a map chunk is generated
-- end)

-- minetest.register_globalstep(function(dtime)
--      -- do things every frame
-- end)

--dofile(modname .. "/api.lua")