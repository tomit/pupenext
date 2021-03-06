class AddDownloadsMenu < ActiveRecord::Migration
  def up
    Company.find_each do |company|
      Current.company = company.yhtio

      # Luodaan valikko
      Permission.create!(
        kuka: '',
        sovellus: 'Intranet',
        nimi: 'pupenext/downloads',
        nimitys: 'Download Area',
        laatija: 'admin',
        luontiaika: DateTime.now,
        muuttaja: 'admin',
        muutospvm: DateTime.now,
        jarjestys: 620
      )

      # Lisätään Admin profiiliin
      Permission.create!(
        kuka: 'Admin profiili',
        profiili: 'Admin profiili',
        paivitys: 1,
        sovellus: 'Intranet',
        nimi: 'pupenext/downloads',
        nimitys: 'Download Area',
        laatija: 'admin',
        luontiaika: DateTime.now,
        muuttaja: 'admin',
        muutospvm: DateTime.now,
        jarjestys: 620
      )

      # Lisätään Adminille käyttöoikeus
      admin = User.find_by(kuka: 'admin')

      if admin
        Permission.create!(
          kuka: 'admin',
          user_id: admin.tunnus,
          profiili: 'Admin profiili',
          paivitys: 1,
          sovellus: 'Intranet',
          nimi: 'pupenext/downloads',
          nimitys: 'Download Area',
          laatija: 'admin',
          luontiaika: DateTime.now,
          muuttaja: 'admin',
          muutospvm: DateTime.now,
          jarjestys: 145
        )
      end
    end
  end

  def down
    Company.find_each do |company|
      Current.company = company.yhtio

      Permission.where(nimi: 'pupenext/downloads').delete_all
    end
  end
end
