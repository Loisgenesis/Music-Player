class Data {
  String id;
  String title;
  String pubDate;
  String link;
  String itunesDuration;
  String itunesAuthor;
  String itunesExplicit;
  String itunesSummary;
  String itunesSubtitle;
  String desc;
  String enclosureType;
  String enclosureUrl;
  String itunesImage;

  Data(
      this.id,
      this.title,
      this.pubDate,
      this.link,
      this.itunesDuration,
      this.itunesAuthor,
      this.itunesSummary,
      this.itunesExplicit,
      this.itunesSubtitle,
      this.desc,
      this.enclosureType,
      this.enclosureUrl,
      this.itunesImage);

  static Data getPostFrmJSONPost(dynamic jsonObject) {
    String id = jsonObject['guid']['\$t'];
    String title = jsonObject['title']['\$t'];
    String pubDate = jsonObject['pubDate']['\$t'];
    String link = jsonObject['link']['\$t'];
    String itunesDuration = jsonObject['itunes\$duration']['\$t'];
    String itunesAuthor = jsonObject['itunes\$author']['\$t'];
    String itunesExplicit = jsonObject['itunes\$explicit']['\$t'];
    String itunesSummary = jsonObject['itunes\$summary']['\$t'];
    String itunesSubtitle = jsonObject['itunes\$subtitle']['\$t'];
    String desc = jsonObject['description']['\$t'];
    String enclosureType = jsonObject['enclosure']['type'];
    String enclosureUrl = jsonObject['enclosure']['url'];
    String itunesImage = jsonObject['itunes\$image']['href'];
    return new Data(
        id,
        title,
        pubDate,
        link,
        itunesDuration,
        itunesAuthor,
        itunesSummary,
        itunesExplicit,
        itunesSubtitle,
        desc,
        enclosureType,
        enclosureUrl,
        itunesImage);
  }

  @override
  String toString() {
    return 'Data{id: $id, title: $title, pubDate: $pubDate, link: $link, itunesDuration: $itunesDuration, itunesAuthor: $itunesAuthor, itunesExplicit: $itunesExplicit, itunesSummary: $itunesSummary, itunesSubtitle: $itunesSubtitle, desc: $desc, enclosureType: $enclosureType, enclosureUrl: $enclosureUrl, itunesImage: $itunesImage}';
  }
}