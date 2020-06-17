/*
 * Copyright © 2010 Yuvaraj Pandian T <yuvipanda@yuvi.in>
 * Copyright © 2010 daniel g. siegel <dgsiegel@gnome.org>
 * Copyright © 2008 Filippo Argiolas <filippo.argiolas@gmail.com>
 *
 * Licensed under the GNU General Public License Version 2
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

using Gtk;

[GtkTemplate (ui = "/org/gnome/Cheese/mail.ui")]
public class Cheese.MailDialog : Gtk.Dialog
{
  private GLib.Settings settings;

  [GtkChild]
  private Gtk.Entry inputMail;
  [GtkChild]
  private Gtk.Button buttonCancel;
  [GtkChild]
  private Gtk.Button buttonSend;


  public MailDialog ()
  {
    var gtk_settings = Gtk.Settings.get_default ();
    
    settings = new GLib.Settings ("org.gnome.Cheese");
  }

  [GtkCallback]
  private void on_maildialog_send (Gtk.Button buttonSend)
  {
    inputMail.text = settings.get_string ("input-mail");

    string res = "printf 'Bonjour,\nVous trouverez votre photo en pièce jointe\nMerci\nLe PST borne photo connectée' | mutt -a '/home/pst/Images/Webcam/Photo_PST_Borne_Photo_Connectee.jpg' -s 'Votre photo par le PST: Borne photo connectée' -- %s".printf (inputMail.text);
    Posix.system(res);

    inputMail.text = "";
    settings.set_string ("input-mail", (string)inputMail.text);

    //Sleep pour laisser le temps à la photo de se s'envoyer avant de supprimer
    GLib.MainLoop loop = new GLib.MainLoop ();
    do_stuff.begin ((obj, async_res) => {
    	loop.quit ();
    });
    loop.run ();

    string supprFile = "rm /home/pst/Images/Webcam/Photo_PST_Borne_Photo_Connectee.jpg";
    Posix.system(supprFile);

    this.hide ();
  }


  //Fonctions permettant de faire un sleep
  public async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
    GLib.Timeout.add (interval, () => {
        nap.callback ();
        return false;
      }, priority);
    yield;
  }
  
  private async void do_stuff () {
    yield nap (800);
  }


  [GtkCallback]
  private void on_maildialog_cancel ()
  {
    string supprFile = "rm /home/pst/Images/Webcam/Photo_PST_Borne_Photo_Connectee.jpg";
    Posix.system(supprFile);

    this.hide ();
  }

  [GtkCallback]
  private bool on_delete ()
  {
    string supprFile = "rm /home/pst/Images/Webcam/Photo_PST_Borne_Photo_Connectee.jpg";
    Posix.system(supprFile);

    return this.hide_on_delete ();
  }

  [GtkCallback]
  private void on_maildialog_change (Gtk.Editable inputMail)
  {
    on_maildialog_input();
  }

  private void on_maildialog_input ()
  {
    settings.set_string ("input-mail", (string)inputMail.text);
  }

}
