

                         Yet another NIM Cruncher


===============================================================================
 TABLE OF CONTENTS
===============================================================================

  0. What is this?
  1. Quick Start
  2. Requirements
  3. Installation
  4. Usage
  5. Interactive Mode
    5.1. Initial configuration.
    5.2. Current configuration and move listings.
    5.3. Move commands.
  6. Limitations
  7. Source
  8. Use Terms


===============================================================================
 1. WHAT IS THIS?
===============================================================================

This little program I wrote some time ago computes winning moves for
heap games such as Nim, Lasker's Nim or Kayles and plays against the user.

Rules of a particular game are expected to be presented as a text file
where each line describes a valid move in the format <m1 m2 h1 h2 ...>,
meaning a player is allowed to remove a number of tokens from a pile,
which has to be followed by dividing said pile into either of {h1, h2,
...} of new ones.

INF can be used to represent infinity as value of m2 above.  For
acceptable computation time, the number of different values in
{h1, h2, ...} should not exceed 4 and neither of those values should
exceed 4 -- YMMV, of course (also see the -m option below).

===============================================================================
 1. QUICK START
===============================================================================

To quickly try out the cruncher, run

  $ ./bin/setup.sh
  $ ./bin/yanc.sh -e ${PATH_TO_YOUR_RULES_FILE}.

Should any questions arise, you should be able to find answers by further
studying this document.


===============================================================================
 2. REQUIREMENTS
===============================================================================

To build this software, you'll need to have the MLton compiler installed.
Having strip is recommended.

To run this software, you'll need either of:

  * a working ruby interpreter (from 1.9.3 upwards)

  * a working java runtime environment to make use of jruby runtime library
    (also see Section 2)

as well as a bourne shell compatible interpreter.

To make use of test automation, you'll also need mkdir, cat and, unless you are
using bash, time utilities.


===============================================================================
 3. INSTALLATION
===============================================================================

You may already have gotten a jruby jar file residing inside the ./lib/vendor
dir along with this software.  It has been released under a tri EPL/GLPL/GPL
license, a copy of which you can find in ./lib/vendor/JRUBY_COPYING, along with
its source.

If your copy of this software is missing a suitable jruby runtime, you can
either:

 * run ./bin/setup.sh to try and download it for you (you'll need to
   have wget installed for this) or

 * download jruby-complete jar file from http://www.jruby.org/download
   and place a symbolic link to it named jruby-complete.jar to the ./lib dir or
   have enviroment variable YANC_JRUBY_JAR point to its location.

To make yanc.sh ignore your system ruby installation and run via jruby, you can
set YANC_FORCE_JRUBY environment variable (faster option if you have no SML
compiler to build native extension with).


===============================================================================
 4. USAGE
===============================================================================

For usage and list of options, run

  $ ./bin/yanc.sh -h
.
For sample runs, try

  $ ./test/run_tests.sh interact
  $ ./test/run_tests.sh nimbers

or (this could take some time)

  $ ./test/run_all.sh ; cat ./log/*.new
.
You can play against this software by running

  $ ./bin/yanc.sh ${PATH_TO_RULES_FILE}
.
Sample rulesets may be found inside the ./data/rules dir.


===============================================================================
 5. INTERACTIVE MODE
===============================================================================

5.1. Initial configuration.

Initial configuration can be entered by either using "-e" option and following
onscreen instructions or entering a list of pile heights on a single line,
separated by whitespace -- with latter option, supplying multiple piles of same
height can be done via "count*height" shortcut.  We explicitly allow for piles
of zero height here.


5.2. Current configuration and move listings.

After each move, current piles' configuration will be printed, surrounded by
square brackets (and followed by the configuration's nim number in case of
user's moves), using, again, "count*height" shortcuts where applicable.  Empty
configuration is displayed as [ _ ].

Before software's moves, a list of winning moves will be printed as
" + old_pile -> new_pile(s)" lines, followed by chosen move highlighted by "=>".


5.3. Move commands.

User's moves should be entered as a single line consisiting of

  * height of the pile the move is to operate on
  * list of new pile heights which are to replace the pile in question
    (again, "count*height" shortcut may be used here)

separated by whitespace.  Empty piles can be entered as "0".


===============================================================================
 6. LIMITATIONS
===============================================================================

At the time of writing, run time behaviour is something that has to be
considered when running on larger datasets (for reference, computing "strange
game" nimbers up to 500 takes over 1 minute -- or 5 to 6 minutes without native
extension -- on author's machine).  If you wish to test it on high branching
factor graphs, you may want to consider using the provided "-m" option.


===============================================================================
 7. SOURCE
===============================================================================

Internal workings of this software can be studied by reading ./lib/yanc.rb as
well as ./lib/ext/*.sml files.  Searching for '*.sh' files will reveal the
householding scripts.


===============================================================================
 8. USE TERMS
===============================================================================

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

