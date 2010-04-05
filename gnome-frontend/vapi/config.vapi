/* config.vapi
 *
 * Copyright (C) 2009-2010  troorl
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 * 	troorl <troorl@gmail.com>
 */

[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "config.h")]
namespace Config
{
	public const string GETTEXT_PACKAGE;
	public const string APPNAME;
	public const string LOCALE_DIR;
	public const string APP_VERSION;
	public const string LOGO_PATH;
	public const string LOGO_FRESH_PATH;
	public const string MENTIONS_PATH;
	public const string MENTIONS_FRESH_PATH;
	public const string TIMELINE_PATH;
	public const string TIMELINE_FRESH_PATH;
	public const string DIRECT_PATH;
	public const string PKGDATADIR;
	public const string DIRECT_FRESH_PATH;
	public const string PROGRESS_PATH;
	public const string DIRECT_REPLY_PATH;
	public const string REPLY_PATH;
	public const string RETWEET_PATH;
	public const string DELETE_PATH;
	public const string USERPIC_PATH;
	public const string TEMPLATES_PATH;
	public const string AUTHORS;
}

