class SampleDataCreator
  def initialize(publication: nil, editor: nil)
    @publication = publication
    @editor = editor
  end

  def seed_data
    seed_magazines

    seed_submissions_for_first_magazine
    seed_meeting_for_first_magazine
    publish_first_magazine

    seed_submissions_for_second_magazine
    seed_meeting_for_second_magazine

    seed_submissions_for_third_magazine
    seed_meetings_for_third_magazine

    seed_positions
    return publication
  end
  handle_asynchronously :seed_data

  private

    attr_reader :publication, :editor

    def communicates; @communicates ||= Ability.find_or_create_by_key_and_description 'communicates', "Can see the names of submitters and communicate with them."; end
    def scores;       @scores ||= Ability.find_or_create_by_key_and_description 'scores', "Can enter (and see) scores for all submissions."; end
    def orchestrates; @orchestrates ||= Ability.find_or_create_by_key_and_description 'orchestrates', "Can organize meetings, record attendance, publish magazines, and specify staff."; end
    def views;        @views ||= Ability.find_or_create_by_key_and_description 'views', "Can view meetings and attendees."; end
    def disappears;   @disappears ||= Ability.find_or_create_by_key_and_description 'disappears', "Submitters & attendees are automatically added to this group. It will disappear once the magazine is published."; end

    def seed_magazines
      @magazines = [
        seed_first_magazine,
        seed_second_magazine,
        seed_third_magazine,
      ]
    end
    alias :magazines :seed_magazines

    def mag1
      return @mag1 if defined? @mag1
      @mag1 ||= Magazine.find_or_create_by_nickname_and_title_and_publication_id('sample published issue', "#{publication.name} vol. 1", publication.id)
      @mag1.update_attributes(
        :accepts_submissions_from  => Time.zone.now - 12.months,
        :accepts_submissions_until => Time.zone.now - 6.months,
        :cover_art_file_name => "sample-cover-1.jpg",
        :cover_art_content_type => "image/jpeg",
        :cover_art_file_size => 340181,
        :cover_art_updated_at => Time.zone.now,
      )
      @mag1
    end
    alias :seed_first_magazine :mag1

    def mag2
      return @mag2 if defined? @mag2
      @mag2 ||= Magazine.find_or_create_by_nickname_and_title_and_publication_id('sample published issue', "#{publication.name} vol. 2", publication.id)
      @mag2.update_attributes(
        :accepts_submissions_from  => Time.zone.now - 6.months + 1.day,
        :accepts_submissions_until => Time.zone.now - 2.weeks,
        :cover_art_file_name => "sample-cover-2.jpg",
        :cover_art_content_type => "image/jpeg",
        :cover_art_file_size => 558488,
        :cover_art_updated_at => Time.zone.now,
      )
      @mag2
    end
    alias :seed_second_magazine :mag2

    def mag3
      @mag3 ||= Magazine.find_or_create_by_nickname_and_publication_id('next', publication.id)
    end
    alias :seed_third_magazine :mag3

    def positions
      @positions ||= magazines.inject([]) do |positions, mag|
        positions << Position.find_or_create_by_magazine_id_and_name(mag.id, "Editor")
        positions << Position.find_or_create_by_magazine_id_and_name(mag.id, "Coeditor")
        positions << Position.find_or_create_by_magazine_id_and_name(mag.id, "Staff")
        positions
      end
    end

    def add_abilities_to_positions
      positions.each do |position|
        add_appropriate_abilities_to(position)
      end
    end

    def add_appropriate_abilities_to(position)
      case position.name
      when "Editor"
        PositionAbility.find_or_create_by_position_id_and_ability_id(position.id, communicates.id)
        PositionAbility.find_or_create_by_position_id_and_ability_id(position.id, scores.id)
        PositionAbility.find_or_create_by_position_id_and_ability_id(position.id, orchestrates.id)
      when "Coeditor"
        PositionAbility.find_or_create_by_position_id_and_ability_id(position.id, scores.id)
        PositionAbility.find_or_create_by_position_id_and_ability_id(position.id, orchestrates.id)
      when "Staff"
        PositionAbility.find_or_create_by_position_id_and_ability_id(position.id, views.id)
      end
    end

    def seed_positions
      positions.select{ |pos| pos.name == "Editor" }.map do |position|
        Role.find_or_create_by_position_id_and_person_id(position.id, editor.id)
      end
      add_abilities_to_positions
    end

    def publish_first_magazine
      mag1.publish published_submissions
      mag1.notify_authors_of_published_magazine
    end

    def dummy_person
      @dummy_person ||= Person.find_or_create_by_email_and_primary_publication_id("support+dummy@publishist.com", Publication.first.id)
    end

    def public_domain_works
      [ { title: "The Fiddler of Dooney", pseudonym: "W B Yeats", body: "When I play on my fiddle in Dooney <br>Folk dance like a wave of the sea <br>My cousin is priest in Kilvarnet <br>My brother in Moharabuiee <br> <br>I passed my brother and cousin: <br>They read in their books of prayer; <br>I read in my book of songs <br>I bought at the Sligo fair.  <br> <br>When we come at the end of time, <br>To Peter sitting in state, <br>He will smile on the three old spirits, <br>But call me first through the gate; <br> <br>For the good are always the merry, <br>Save by an evil chance, <br>And the merry love the fiddle <br>And the merry love to dance: <br> <br>And when the folk there spy me, <br>They will all come up to me, <br>With ‘Here is the fiddler of Dooney!’ <br>And dance like a wave of the sea.", },
        { title: "The Need of Being Versed in Country Things", pseudonym: "Robert Frost", body: "The house had gone to bring again <br>To the midnight sky a sunset glow.  <br>Now the chimney was all of the house that stood, <br>Like a pistil after the petals go.  <br> <br>The barn opposed across the way, <br>That would have joined the house in flame <br>Had it been the will of the wind, was left <br>To bear forsaken the place’s name.  <br> <br>No more it opened with all one end <br>For teams that came by the stony road        1 <br>To drum on the floor with scurrying hoofs <br>And brush the mow with the   summer load.  <br> <br>The birds that came to it through the air <br>At broken windows flew out and in, <br>Their murmur more like the sigh we sigh <br>From too much dwelling on what has been.  <br> <br>Yet for them the lilac renewed its leaf, <br>And the aged elm, though touched with fire; <br>And the dry pump flung up an awkward arm; <br>And the fence post carried a strand of wire.  <br> <br>For them there was really nothing sad.  <br>But though they rejoiced in the nest they kept, <br>One had to be versed in country things <br>Not to believe the phoebes wept.", },
        { title: "City of Orgies", pseudonym: "Walt Whitman", body: "City of orgies, walks and joys, <br>City whom that I have lived and sung in your midst will one day make <br>Not the pageants of you, not your shifting tableaus, your &nbsp;&nbsp;&nbsp; <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; spectacles, repay me, <br>Not the interminable rows of your houses, nor the ships at the wharves, <br>Nor the processions in the streets, nor the bright windows with &nbsp;&nbsp;&nbsp;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  goods in them, <br>Nor to converse with learn'd persons, or bear my share in the soiree &nbsp;&nbsp;&nbsp; <br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; or feast; <br>Not those, but as I pass O Manhattan, your frequent and swift flash &nbsp;&nbsp;&nbsp;<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  of eyes offering me love, <br>Offering response to my own--these repay me, <br>Lovers, continual lovers, only repay me.", },
        { title: "Magdalen Walks", pseudonym: "Oscar Wilde", body: "The little white clouds are racing over the sky, <br>&nbsp;&nbsp;&nbsp;&nbsp;And the fields are strewn with the gold of the flower of March, <br>&nbsp;&nbsp;&nbsp;&nbsp;The daffodil breaks under foot, and the tasselled larch <br>Sways and swings as the thrush goes hurrying by.  <br> <br>A delicate odour is borne on the wings of the morning breeze, <br>&nbsp;&nbsp;&nbsp;&nbsp;The odour of deep wet grass, and of brown new-furrowed earth, <br>&nbsp;&nbsp;&nbsp;&nbsp;The birds are singing for joy of the Spring's glad birth, <br>Hopping from branch to branch on the rocking trees.  <br> <br>And all the woods are alive with the murmur and sound of Spring, <br>&nbsp;&nbsp;&nbsp;&nbsp;And the rose-bud breaks into pink on the climbing briar, <br>&nbsp;&nbsp;&nbsp;&nbsp;And the crocus-bed is a quivering moon of fire <br>Girdled round with the belt of an amethyst ring.  <br> <br>And the plane to the pine-tree is whispering some tale of love <br>&nbsp;&nbsp;&nbsp;&nbsp;Till it rustles with laughter and tosses its mantle of green, <br>&nbsp;&nbsp;&nbsp;&nbsp;And the gloom of the wych-elm's hollow is lit with the iris sheen <br>Of the burnished rainbow throat and the silver breast of a dove.  <br> <br>See! the lark starts up from his bed in the meadow there, <br>&nbsp;&nbsp;&nbsp;&nbsp;Breaking the gossamer threads and the nets of dew, <br>&nbsp;&nbsp;&nbsp;&nbsp;And flashing adown the river, a flame of blue!  <br>The kingfisher flies like an arrow, and wounds the air.", },
        { title: "Break, Break, Break", pseudonym: "Alfred Tennyson", body: "Break, break, break, <br>On thy cold gray stones, O Sea!  <br>And I would that my tongue could utter <br>The thoughts that arise in me.  <br> <br>O well for the fisherman's boy, <br>That he shouts with his sister at play!  <br>O well for the sailor lad, <br>That he sings in his boat on the bay!  <br> <br>And the stately ships go on <br>To their haven under the hill: <br>But O for the touch of a vanish'd hand, <br>And the sound of a voice that is still!  <br> <br>Break, break, break, <br>At the foot of thy crags, O Sea!  <br>But the tender grace of a day that is dead <br>Will never come back to me.", },
        { title: "Piccadilly Circus at Night", pseudonym: "D H Lawerence", body: "When into the night the yellow light is roused like dust above the towns, <br>Or like a mist the moon has kissed from off a pool in the midst of the downs, <br> <br>Our faces flower for a little hour pale and uncertain along the street, <br>Daisies that waken all mistaken white-spread in expectancy to meet <br> <br>The luminous mist which the poor things wist was dawn arriving across the sky, <br>When dawn is far behind the star the dust-lit town has driven so high.  <br> <br>All the birds are folded in a silent ball of sleep, <br>All the flowers are faded from the asphalt isle in the sea, <br>Only we hard-faced creatures go round and round, and keep <br>The shores of this innermost ocean alive and illusory.  <br> <br>Wanton sparrows that twittered when morning looked in at their eyes <br>And the Cyprian's pavement-roses are gone, and now it is we <br>Flowers of illusion who shine in our gauds, make a Paradise <br>On the shores of this ceaseless ocean, gay birds of the town-dark sea.", },
        { title: "Ode on a Grecian Urn", pseudonym: "John Keats", body: "Thou still unravished bride of quietness!  <br>Thou foster-child of silence and slow time, <br>Sylvan historian, who canst thus express <br>A flow'ry tale more sweetly than our rhyme: <br>What leaf-fringed legend haunts about thy shape <br>Of deities or mortals, or of both, <br>In Tempe or the dales of Arcady?  <br>What men or gods are these? What maidens loth?  <br>What mad pursuit? What struggle to escape?  <br>What pipes and timbrels? What wild ecstasy?  <br> <br>Heard melodies are sweet, but those unheard <br>Are sweeter; therefore, ye soft pipes, play on; <br>Not to the sensual ear, but, more endeared, <br>Pipe to the spirit ditties of no tone: <br>Fair youth, beneath the trees, thou canst not leave <br>Thy song, nor ever can those trees be bare; <br>Bold Lover, never, never canst thou kiss, <br>Though winning near the goal -yet, do not grieve; <br>She cannot fade, though thou hast not thy bliss, <br>For ever wilt thou love, and she be fair!  <br> <br>Ah, happy, happy boughs! that cannot shed <br>Your leaves, nor ever bid the Spring adieu; <br>And, happy melodist, unwearied, <br>For ever piping songs for ever new; <br>More happy love! more happy, happy love!  <br>For ever warm and still to be enjoyed, <br>For ever panting and for ever young; <br>All breathing human passion far above, <br>That leaves a heart high-sorrowful and cloyed, <br>A burning forehead, and a parching tongue.  <br> <br>Who are these coming to the sacrifice?  <br>To what green altar, O mysterious priest, <br>Lead'st thou that heifer lowing at the skies, <br>And all her silken flanks with garlands drest?  <br>What little town by river or sea-shore, <br>Or mountain-built with peaceful citadel, <br>Is emptied of its folk, this pious morn?  <br>And, little town, thy streets for evermore <br>Will silent be; and not a soul to tell <br>Why thou art desolate, can e'er return.  <br> <br>O Attic shape! Fair attitude! with brede <br>Of marble men and maidens overwrought, <br>With forest branches and the trodden weed; <br>Thou, silent form, dost tease us out of thought <br>As doth eternity: Cold pastoral!  <br>When old age shall this generation waste, <br>Thou shalt remain, in midst of other woe <br>Than ours, a friend to man, to whom thou sayst, <br>\"Beauty is truth, truth beauty,\" -that is all <br>Ye know on earth, and all ye need to know.", },
        { title: "Love's Philosophy", pseudonym: "Percy Shelley", body: "The Fountains mingle with the Rivers <br>And the Rivers with the Oceans, <br>The winds of Heaven mix forever <br>With a sweet emotion; <br>Nothing in the world is single; <br>All things by a law divine <br>In one spirit meet and mingle.  <br>Why not I with thine? -- <br> <br>See the mountains kiss high Heaven <br>And the waves clasp one another; <br>No sister-flower would be forgiven <br>If it disdained its brother, <br>And the sunlight clasps the earth <br>And the moonbeams kiss the sea: <br>What is all this sweet work worth <br>If thou kiss not me?", },
        { title: "Sonnet XVIII", pseudonym: "The Bard", body: "Shall I compare thee to a summer's day?  <br>Thou art more lovely and more temperate: <br>Rough winds do shake the darling buds of May, <br>and summer's lease hath all too short a date: <br>Sometimes too hot the eye of heaven shines <br>And often is his gold complexion dimmed; <br>And every fair from fair sometime declines, <br>By chance or nature's changing course untrimmed; <br>But thy eternal summer shall not fade <br>Nor lose possession of that fair thou owest; <br>Nor shall Death brag thou wanderest in his shade, <br>When in eternal lines to time thou growest: <br>&nbsp;&nbsp;&nbsp;&nbsp;So long as men can breathe or eyes can see, <br>&nbsp;&nbsp;&nbsp;&nbsp;So long lives this and this gives life to thee.", },
        { title: "The Garden of Love", pseudonym: "William Blake", body: "I laid me down upon a bank, <br>Where Love lay sleeping; <br>I heard among the rushes dank <br>Weeping, weeping.  <br> <br>Then I went to the heath and the wild, <br>To the thistles and thorns of the waste; <br>And they told me how they were beguiled, <br>Driven out, and compelled to the chaste.  <br> <br>I went to the Garden of Love, <br>And saw what I never had seen; <br>A Chapel was built in the midst, <br>Where I used to play on the green.  <br> <br>And the gates of this Chapel were shut <br>And \"Thou shalt not,\" writ over the door; <br>So I turned to the Garden of Love <br>That so many sweet flowers bore.  <br> <br>And I saw it was filled with graves, <br>And tombstones where flowers should be; <br>And priests in black gowns were walking their rounds, <br>And binding with briars my joys and desires.", },
      ]
    end

    def sample_works_by_editor
      [ { title: "Sample reject", body: "This is a sample work that was created at sign up. <i>#{publication.name}</i> didn't like it enough to publish it. :-(", },
        { title: "Sample published", body: "This is a sample work that was created at sign up. <i>#{publication.name}</i> apparently liked it enough to publish it!", },
        { title: "Sample submission, so you can learn. Click this here title!", body: "You can see everything you've submitted, had published, <i>&c</i> on <a href='/people/#{editor.slug}'>your profile page</a>.", },
      ]
    end

    def seed_submissions_for_first_magazine
      seed_published_submissions
      seed_rejected_submissions
    end

    def published_submissions
      return @published_submissions if defined? @published_submissions
      @published_submissions = public_domain_works.first(3).map do |submission|
        create_submission_for(mag1, from: submission)
      end
      @published_submissions << create_submission_for(mag1, from: sample_works_by_editor[1], author: editor)
    end
    alias :seed_published_submissions :published_submissions

    def rejected_submissions
      @rejected_submissions ||= [
        create_submission_for(mag1, from: sample_works_by_editor[0], author: editor)
      ]
    end
    alias :seed_rejected_submissions :rejected_submissions

    def seed_submissions_for_second_magazine
      public_domain_works[3..6].map do |submission|
        create_submission_for(mag2, from: submission)
      end
    end

    def new_submissions
      return @new_submissions if defined? @new_submissions
      @new_submissions = public_domain_works.last(3).map do |submission|
        create_submission_for(mag3, from: submission, submission_date: Time.zone.now)
      end
      @new_submissions << create_submission_for(mag3, from: sample_works_by_editor[2], submission_date: Time.zone.now, author: editor)
    end
    alias :seed_submissions_for_third_magazine :new_submissions

    def create_submission_for(magazine, options)
      from = options.fetch(:from)
      date = options[:submission_date] || Time.zone.now - 5.months
      author = options[:author] || dummy_person
      submission = Submission.find_or_create_by_magazine_id_and_author_id_and_title(magazine.id, author.id, from[:title])
      submission.update_attributes(
        :publication_id => publication.id,
        :state => :submitted,
        :body => from[:body],
        :created_at => date,
        :pseudonym => pseudonym_for(submission, from[:pseudonym])
      )
      submission
    end

    def pseudonym_for(submission, pseudonym)
      return unless pseudonym
      Pseudonym.find_or_create_by_submission_id_and_name_and_link_to_profile(submission.id, pseudonym, false)
    end

    def seed_meeting_for_first_magazine
      meeting = Meeting.find_or_create_by_magazine_id(mag1.id)
      meeting.update_attributes(
        :datetime => Time.zone.now - 7.months,
        :question => "What is your spirit animal?"
      )
      review_submissions_at(meeting, mag1.submissions(:all))
    end

    def seed_meeting_for_second_magazine
      meeting = Meeting.find_or_create_by_magazine_id(mag2.id)
      meeting.update_attributes(
        :datetime => Time.zone.now - 2.months,
        :question => "What was your first pet?"
      )
      review_submissions_at(meeting, mag2.submissions(:all))
    end

    def seed_meetings_for_third_magazine
      meeting1 = Meeting.find_or_create_by_magazine_id_and_question(mag3.id, "Who is your alter ego and what is he/she/it like?")
      meeting1.update_attribute :datetime, Time.zone.now + 2.weeks
      meeting2 = Meeting.find_or_create_by_magazine_id_and_question(mag3.id, "What's the ideal place to have a #{publication.name} social?")
      meeting2.update_attribute :datetime, Time.zone.now + 4.weeks
    end

    def review_submissions_at(meeting, subs)
      subs.map do |submission|
        Packlet.find_or_create_by_meeting_id_and_submission_id(meeting.id, submission.id)
      end
      add_scores_to_meeting(meeting)
    end

    def add_scores_to_meeting(meeting)
      attendees_for(meeting).each do |attendee|
        meeting.packlets.each do |packlet|
          score = Score.find_or_create_by_packlet_id_and_attendee_id(packlet.id, attendee.id)
          score.update_attributes(:amount => rand(1..10), :entered_by_coeditor => true)
        end
      end
    end

    def attendees_for(meeting)
      [ Attendee.find_or_create_by_meeting_id_and_person_id_and_answer(meeting.id, editor.id, "Blue Whale"),
        Attendee.find_or_create_by_meeting_id_and_person_name_and_answer(meeting.id, "Shane Claiborne", "Humpback Whale"),
        Attendee.find_or_create_by_meeting_id_and_person_name_and_answer(meeting.id, "Mother Teresa", "Anenome"),
        Attendee.find_or_create_by_meeting_id_and_person_name_and_answer(meeting.id, "Rob Bell", "Dog"),
        Attendee.find_or_create_by_meeting_id_and_person_name_and_answer(meeting.id, "Tim Keller", "Stallion"),
        Attendee.find_or_create_by_meeting_id_and_person_name_and_answer(meeting.id, "Derek Webb", "Antelope"),
        Attendee.find_or_create_by_meeting_id_and_person_name_and_answer(meeting.id, "Sharon Groves", "Turtle"),
        Attendee.find_or_create_by_meeting_id_and_person_name_and_answer(meeting.id, "Nadia Bolz-Weber", "Albatross"),
        Attendee.find_or_create_by_meeting_id_and_person_name_and_answer(meeting.id, "Krista Tippett", "Paramecium"),
        Attendee.find_or_create_by_meeting_id_and_person_name_and_answer(meeting.id, "Caitlin Breedlove", "Turtle dove"),
        Attendee.find_or_create_by_meeting_id_and_person_name_and_answer(meeting.id, "Tonyia M. Rawls", "a lamb"),
        Attendee.find_or_create_by_meeting_id_and_person_name_and_answer(meeting.id, "T. Anthony Spearman", "Lion!"),
        Attendee.find_or_create_by_meeting_id_and_person_name_and_answer(meeting.id, "Phyllis Tickle", "Bonobo"),
      ]
    end

end
