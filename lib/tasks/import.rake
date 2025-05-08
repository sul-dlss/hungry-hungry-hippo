# frozen_string_literal: true

# Has department role. See https://github.com/sul-dlss/hungry-hungry-hippo/issues/1298
WITH_DEPARTMENT_ROLES = ['druid:ry742gn4021',
                         'druid:bz017bq7668',
                         'druid:rh614yz5124',
                         'druid:cy977mf7313',
                         'druid:th926tb9400',
                         'druid:jr652rx2541',
                         'druid:cv304vk9883',
                         'druid:gp361hz5082',
                         'druid:mr373pn0879',
                         'druid:rt187sc7864',
                         'druid:qm274fz0921',
                         'druid:jw683dy3472',
                         'druid:gw249gv9778',
                         'druid:bc865wh0982',
                         'druid:mp512fy0405',
                         'druid:xn156wf1698',
                         'druid:qm695ny4920',
                         'druid:th866bg2433',
                         'druid:wp105cx4248',
                         'druid:wx314xy1580',
                         'druid:zb309sj9103',
                         'druid:hn955wp7476',
                         'druid:tk726kd4859',
                         'druid:sv915zg2311',
                         'druid:cd054gf2198',
                         'druid:bx852hj9394',
                         'druid:ng517gq2855',
                         'druid:xq419cv5789',
                         'druid:ft697cq3835',
                         'druid:kn730cj8320',
                         'druid:tp271xt6869',
                         'druid:tj546dj4178',
                         'druid:vh359gs8861',
                         'druid:hw648fn9717',
                         'druid:hp391tw8759',
                         'druid:tm700dc0091',
                         'druid:bj798mj3298',
                         'druid:cr877ww8519',
                         'druid:yj661fn2246',
                         'druid:mh136tx4998',
                         'druid:kh056qg9382',
                         'druid:cs479vm9405',
                         'druid:cf448xg0843',
                         'druid:sd778jj5694',
                         'druid:wk365dw7214',
                         'druid:db999xp7109',
                         'druid:gw776xm8585',
                         'druid:dk727vk3988',
                         'druid:vm081mg6032',
                         'druid:nr644yx3574',
                         'druid:tn463rr9524',
                         'druid:kc246wk4441',
                         'druid:dz767bb5203',
                         'druid:ry172nn8505',
                         'druid:nd602zq5759',
                         'druid:kq793ry0381',
                         'druid:yz292hc4054',
                         'druid:zd236qb8595',
                         'druid:vg673tr9428',
                         'druid:pt103ty8267',
                         'druid:vd777dg4556',
                         'druid:vr862zx5273',
                         'druid:rb946vd1052',
                         'druid:tv267fc7641',
                         'druid:hk876zh3143',
                         'druid:hy722vw9067',
                         'druid:cf149ht2223',
                         'druid:bp960ts2244',
                         'druid:jy336zh7440',
                         'druid:bm013gp4453',
                         'druid:qq958gt6387',
                         'druid:rc763nv9924',
                         'druid:vy708hw6382',
                         'druid:zs002kt3728',
                         'druid:kd110gb2567',
                         'druid:wn531hk6485',
                         'druid:mv626xk6159',
                         'druid:td164tm1796',
                         'druid:tw573gd8633',
                         'druid:kj095nm6578',
                         'druid:qs509jg1024',
                         'druid:xd261ft7746',
                         'druid:qn178kb2231',
                         'druid:mh237tg6127',
                         'druid:tj788xg5427',
                         'druid:rc071fd9245',
                         'druid:sx677dn3514',
                         'druid:hn011kb3770',
                         'druid:wg105nm5963',
                         'druid:rw873vp5865',
                         'druid:ft767zz6367',
                         'druid:cq284vh8219',
                         'druid:mq610rq1094',
                         'druid:bd836yq4987',
                         'druid:sv580tb5150',
                         'druid:db192yt8913',
                         'druid:cs713dg0732',
                         'druid:mm463rk2016',
                         'druid:mm543jr6552',
                         'druid:gw529wt5354',
                         'druid:fy040rv4004',
                         'druid:wm135gp2721',
                         'druid:vp366kq1885',
                         'druid:yy900yt2903',
                         'druid:rz322qx9907',
                         'druid:vw155nh8241',
                         'druid:hd310tx5135',
                         'druid:wy512gg0435',
                         'druid:qg507nz0616',
                         'druid:rk203zq9254',
                         'druid:kt858bb5025',
                         'druid:zh004rv6465',
                         'druid:hj114zt7224',
                         'druid:bf279rr2328',
                         'druid:ns642ps1911',
                         'druid:wk768gh7709',
                         'druid:sr785ns0338',
                         'druid:xr154rp8748',
                         'druid:hq778yt7524',
                         'druid:kq565vk7202',
                         'druid:rk012tq9683',
                         'druid:qn889fz2580',
                         'druid:dp322nd5637',
                         'druid:jj393yw9998',
                         'druid:rk793qg5671',
                         'druid:cv596gc3865',
                         'druid:jb583cr4817',
                         'druid:qb074vx0459',
                         'druid:sh539kz3178',
                         'druid:jg930km8025',
                         'druid:xf925xp9052',
                         'druid:cw216vw1344',
                         'druid:cc008rx2375',
                         'druid:cj326jb8300',
                         'druid:fh441mm7851',
                         'druid:yx926fy9172',
                         'druid:jw897yc9834',
                         'druid:rx405gd9278',
                         'druid:kg187pj4784',
                         'druid:nz628sh5376',
                         'druid:jz326qf1474',
                         'druid:jh547hc0050',
                         'druid:hn691pg8367',
                         'druid:jk068xg5645',
                         'druid:wx498km4203',
                         'druid:gg066cy0440',
                         'druid:hv979pp9576',
                         'druid:zr879wd8349',
                         'druid:mq326dq1556',
                         'druid:xt972yv7103',
                         'druid:bj155mm4147',
                         'druid:wd599zj7735',
                         'druid:ps239gf1021',
                         'druid:qk793hh0195',
                         'druid:jy906cm4775',
                         'druid:pc490xr0539',
                         'druid:pq755ps9247',
                         'druid:xc151jn0840',
                         'druid:fp469ff4166',
                         'druid:hd542bg3248',
                         'druid:wz755ds4137',
                         'druid:nb999zf0622',
                         'druid:rd605cr6236',
                         'druid:pd112mx1452',
                         'druid:hf313sb0308',
                         'druid:bq773rk7975',
                         'druid:vz275qb0935',
                         'druid:cj065mz9424',
                         'druid:vz239pw2001',
                         'druid:jz001gv7236',
                         'druid:fb966th2333',
                         'druid:bf094rb4252',
                         'druid:yq442fh7161',
                         'druid:vp935tn3708',
                         'druid:fr157ss6352',
                         'druid:jy709yz8361',
                         'druid:rv768zw2846',
                         'druid:wn656pv7309',
                         'druid:gw946sh9743',
                         'druid:px312dg4173',
                         'druid:mf645sg7780',
                         'druid:qg181jv7812',
                         'druid:kj652qd7014',
                         'druid:fw391xc6569',
                         'druid:tz804fc0550',
                         'druid:hq116jk0068',
                         'druid:fw833wt7474',
                         'druid:qb619jz9911',
                         'druid:my785xr4262',
                         'druid:fz219sn1931',
                         'druid:wc079tx1822',
                         'druid:rd947bh9956',
                         'druid:bx240rk8260',
                         'druid:wq443nv2994',
                         'druid:py978gh8681',
                         'druid:mw375sr7697',
                         'druid:hd270tn0985',
                         'druid:dq489kg3466',
                         'druid:dq361st5250',
                         'druid:wh755zt9322',
                         'druid:ng701jh0332',
                         'druid:ks516zw7792',
                         'druid:kg462ky4635',
                         'druid:kf612yp2008',
                         'druid:qt235tv1296',
                         'druid:fm703kj1299',
                         'druid:tf883dq9902',
                         'druid:zw559rq4639',
                         'druid:vn328kn3815',
                         'druid:tw622hp2288',
                         'druid:cd689jk3199',
                         'druid:xt401bv3017',
                         'druid:tc210gs0021',
                         'druid:wv714cf7041',
                         'druid:tb752wd1307',
                         'druid:vg469sc8664',
                         'druid:jh144sj8005',
                         'druid:ym017jz7996',
                         'druid:qw380sv6849',
                         'druid:ng049bf0279',
                         'druid:ss675ck8005']

# See https://github.com/sul-dlss/happy-heron/issues/3715
WITH_DISTRIBUTOR_ROLES = ['druid:rg315vk9793',
                          'druid:rg825jf7958',
                          'druid:zn179xf4479',
                          'druid:sc150ft4611',
                          'druid:gm384nn3146',
                          'druid:tj682yd8532',
                          'druid:yp464cc5056',
                          'druid:pn116pv4512']

namespace :import do
  desc 'Import collections from json'
  # collections.json can be generated in H2 for some set of collections with:
  # collections = Collection.joins(:head).where.not('head.state': 'decommissioned')
  # collections_json = collections.map do |collection|
  #   collection.as_json(include: [:creator, :depositors, :reviewed_by, :managed_by]).tap do |collection_hash|
  #     # Map H2 license ids to URIs
  #     ['required_license', 'default_license'].each do |field|
  #       next if (license_id = collection_hash[field]).blank?
  #       collection_hash[field] = License.find(license_id).uri
  #     end
  #   end
  # end
  # File.write('collections.json', JSON.pretty_generate(collections_json))
  # Importing is idempotent, so you can run this multiple times.
  # It will raise an error if the collection cannot be roundtripped.
  task :collections, [:filename] => :environment do |_t, args|
    Rails.application.config.action_mailer.perform_deliveries = false

    collections_hash = JSON.parse(File.read(args[:filename] || 'collections.json'))
    collections_hash.each_with_index do |collection_hash, index|
      next unless collection_hash['druid']

      puts "Importing collection #{collection_hash['druid']} (#{index + 1}/#{collections_hash.length})"
      CollectionImporter.call(collection_hash:)
    rescue CatalogedImportError
      puts "Skipping cataloged collection #{collection_hash['druid']} (#{index + 1}/#{collections_hash.length})"
      # rescue UnexpectedApoImportError
      #   puts "Skipping collection with unexpected APO #{collection_hash['druid']} (#{index + 1}/#{collections_hash.length})"
    end
  end

  desc 'Import works from json'
  # works.json can be generated in H2 for some set of works with:
  #   works = Work.joins(:head).where.not('head.state': 'decommissioned')
  #   works_json = works.map {|work| work.as_json(include: [:owner])}
  #   File.write('works.json', JSON.pretty_generate(works_json))
  # Importing is idempotent, so you can run this multiple times.
  # It will raise an error if the work cannot be roundtripped or the collection cannot be found.
  task :works, [:filename] => :environment do |_t, args|
    Rails.application.config.action_mailer.perform_deliveries = false

    works_hash = JSON.parse(File.read(args[:filename] || 'works.json'))
    works_hash.each_with_index do |work_hash, index|
      next unless work_hash['druid']

      if (WITH_DEPARTMENT_ROLES + WITH_DISTRIBUTOR_ROLES).include?(work_hash['druid'])
        puts "Skipping work #{work_hash['druid']} (#{index + 1}/#{works_hash.length})"
        next
      end

      puts "Importing work #{work_hash['druid']} (#{index + 1}/#{works_hash.length})"
      WorkImporter.call(work_hash:)
    # rescue UnexpectedApoImportError
    #   puts "Skipping work with unexpected APO #{work_hash['druid']} (#{index + 1}/#{works_hash.length})"
    rescue CatalogedImportError
      puts "Skipping cataloged work #{work_hash['druid']} (#{index + 1}/#{works_hash.length})"
    rescue HydrusImportError
      puts "Skipping Hydrus work #{work_hash['druid']} (#{index + 1}/#{works_hash.length})"
    end
  end

  desc 'Test import works from json'
  # works.json can be generated as shown above.
  # works_cocina.jsonl can be generated in H2 for some set of works with:
  #   File.open('works_cocina.jsonl', 'w') do |f|
  #     Work.joins(:head).where('head.state': 'deposited').find_each.with_index do |w, i|
  #       puts "#{w.druid} (#{i + 1})"
  #       c = CocinaGenerator::DROGenerator.generate_model(work_version: w.head, cocina_obj: Repository.find(w.druid))
  #       f.write("#{c.to_json}\n")
  #     end
  #   end
  # It will raise an error if the work cannot be roundtripped or the collection cannot be found.
  task :test_works, %i[cocina_filename] => :environment do |_t, args|
    File.foreach(args[:cocina_filename] || 'works_cocina.jsonl').with_index do |line, index|
      cocina_object = Cocina::Models.with_metadata(Cocina::Models.build(JSON.parse(line)), 'fakelock')

      # next if WITH_DEPARTMENT_ROLES.include?(cocina_object.externalIdentifier)

      puts "Testing work #{cocina_object.externalIdentifier}} (#{index + 1})"

      collection = Collection.find_by(druid: Cocina::Parser.collection_druid_for(cocina_object:))
      unless collection
        puts "Skipping work with missing collection #{cocina_object.externalIdentifier}} (#{index + 1})"
        next
      end

      work_form = Form::WorkMapper.call(cocina_object:, doi_assigned: false, agree_to_terms: true,
                                        version_description: '', collection:)
      content = Contents::Builder.call(cocina_object:, user: User.first)
      raise 'Roundtripping failed' unless WorkRoundtripper.call(work_form:, cocina_object:, content:)
    end
  end
end
