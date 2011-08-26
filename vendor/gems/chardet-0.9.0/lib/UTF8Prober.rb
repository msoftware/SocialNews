######################## BEGIN LICENSE BLOCK ########################
# The Original Code is mozilla.org code.
#
# The Initial Developer of the Original Code is
# Netscape Communications Corporation.
# Portions created by the Initial Developer are Copyright (C) 1998
# the Initial Developer. All Rights Reserved.
#
# Contributor(s):
#   Hui (zhengzhengzheng@gmail.com) - port to Ruby
#   Mark Pilgrim - first port to Python
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301  USA
######################### END LICENSE BLOCK #########################

require 'UniversalDetector'
require 'CharSetProber'
require 'CodingStateMachine'
require 'MBCSSM'

module UniversalDetector
    ONE_CHAR_PROB = 0.5

    class UTF8Prober < CharSetProber
        def initialize
            super()
            @_mCodingSM = CodingStateMachine.new(UTF8SMModel)
            reset()
        end

        def reset
            super
            @_mCodingSM.reset()
            @_mNumOfMBChar = 0
        end

        def get_charset_name
            return "utf-8"
        end

        def feed(aBuf) 
            aLen = aBuf.length       
            for i in 0...aLen
                codingState = @_mCodingSM.next_state(aBuf[i])                
                if codingState == :Error
                    @_mState = :NotMe
                    break
                elsif codingState == :ItsMe
                    @_mState = :FoundIt
                    break
                elsif codingState == :Start
                    if @_mCodingSM.get_current_charlen() >= 2:
                        @_mNumOfMBChar += 1
                    end
                end
            end

            if get_state() == :Detecting
                if get_confidence() > SHORTCUT_THRESHOLD
                    @_mState = :FoundIt
                end
            end
            return get_state()
        end

        def get_confidence
            unlike = 0.99
            if @_mNumOfMBChar < 6
                for i in 0...@_mNumOfMBChar
                    unlike = unlike * ONE_CHAR_PROB
                end
                return 1.0 - unlike
            else
                return unlike
            end
        end
    end
end