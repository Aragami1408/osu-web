<?php

/**
 *    Copyright 2015-2018 ppy Pty. Ltd.
 *
 *    This file is part of osu!web. osu!web is distributed with the hope of
 *    attracting more community contributions to the core ecosystem of osu!.
 *
 *    osu!web is free software: you can redistribute it and/or modify
 *    it under the terms of the Affero GNU General Public License version 3
 *    as published by the Free Software Foundation.
 *
 *    osu!web is distributed WITHOUT ANY WARRANTY; without even the implied
 *    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *    See the GNU Affero General Public License for more details.
 *
 *    You should have received a copy of the GNU Affero General Public License
 *    along with osu!web.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace App\Models\Forum;

use Illuminate\Database\Eloquent\Builder;

class ForumTrack extends Model
{
    protected $table = 'phpbb_forums_track';
    protected $guarded = [];

    public $timestamps = false;
    protected $dates = ['mark_time'];
    protected $dateFormat = 'U';

    // Allows save/update/delete to work with composite primary keys.
    protected function setKeysForSaveQuery(Builder $query)
    {
        return $query->where([
            'forum_id' => $this->forum_id,
            'user_id' => $this->user_id,
        ]);
    }
}
