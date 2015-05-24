/*  This file is part of corebird, a Gtk+ linux Twitter client.
 *  Copyright (C) 2013 Timm Bäder
 *
 *  corebird is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  corebird is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with corebird.  If not, see <http://www.gnu.org/licenses/>.
 */

public class NotificationItem : GLib.Object {
  public static int TYPE_RETWEET  = 1;
  public static int TYPE_FAVORITE = 2;
  public static int TYPE_FOLLOWED = 3;

  public signal void changed ();

  public int64 id;
  public int type = -1;
  public string heading;
  public string body;
}


// XXX This shouldn't really need to be a class...
public class UserIdentity : GLib.Object {
  public string name;
  public string screen_name;
  public int64  user_id;
}

public class MultipleUserNotificationItem : NotificationItem {
  public Gee.ArrayList<UserIdentity> identities = new Gee.ArrayList<UserIdentity> ();
  protected string[] headings = new string[4];

  public MultipleUserNotificationItem () {}


  protected string screen_name_link (int i) {
    return "<span underline='none'><a href='@%s'>@%s</a></span>"
           .printf (this.identities.get (i).user_id.to_string (),
                    this.identities.get (i).screen_name);
  }

  public virtual void build_text () {
    if (identities.size == 1) {
      this.heading = headings[0].printf (screen_name_link (0));
    } else if (identities.size == 2) {
      this.heading = headings[1].printf (screen_name_link (0),
                                         screen_name_link (1));
    } else if (identities.size == 3) {
      this.heading = headings[2].printf (screen_name_link (0),
                                         screen_name_link (1),
                                         screen_name_link (2));
    } else if (identities.size > 3) {
      this.heading = headings[3].printf (screen_name_link (identities.size - 1),
                                         screen_name_link (identities.size - 2),
                                         identities.size - 2);
    }

    this.changed ();
  }
}

public class RTNotificationItem : MultipleUserNotificationItem {
  public RTNotificationItem () {
    this.headings[0] = "%s retweeted you";
    this.headings[1] = "%s and %s retweeted you";
    this.headings[2] = "%s, %s and %s retweeted you";
    this.headings[3] = "%s, %s and %d others retweeted you";
  }
}

public class FavNotificationItem : MultipleUserNotificationItem {
  public FavNotificationItem () {
    this.headings[0] = "%s favorited one of your tweets";
    this.headings[1] = "%s and %s favorited one of your tweets";
    this.headings[2] = "%s, %s and %s favorited one of your tweets";
    this.headings[3] = "%s, %s and %d others favorited one of your tweets";
  }
}

public class FollowNotificationItem : MultipleUserNotificationItem {
  public override void build_text () {
    assert (this.identities.size > 0);

    this.heading = "%s followed you".printf (screen_name_link (this.identities.size - 1));
    if (identities.size > 1) {
      var sb = new StringBuilder ();
      sb.append ("Also: ")
        .append (screen_name_link (this.identities.size - 2));
      for (int i = identities.size - 3; i >= 0; i --) {
        sb.append (",").append (screen_name_link (i));
      }

      this.body = sb.str;
    }

    this.changed ();
  }
}