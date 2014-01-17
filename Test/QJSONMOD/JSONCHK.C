000100120130/* JSON_checker.c */
000200120130
000300120130/* 2007-08-24 */
000400120130
000500120130/*
000600120130Copyright (c) 2005 JSON.org
000700120130
000800120130Permission is hereby granted, free of charge, to any person obtaining a copy
000900120130of this software and associated documentation files (the "Software"), to deal
001000120130in the Software without restriction, including without limitation the rights
001100120130to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
001200120130copies of the Software, and to permit persons to whom the Software is
001300120130furnished to do so, subject to the following conditions:
001400120130
001500120130The above copyright notice and this permission notice shall be included in all
001600120130copies or substantial portions of the Software.
001700120130
001800120130The Software shall be used for Good, not Evil.
001900120130
002000120130THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
002100120130IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
002200120130FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
002300120130AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
002400120130LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
002500120130OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
002600120130SOFTWARE.
002700120130*/
002800120130
002900120130#include <stdlib.h>
003000120130#include <QJSONTXT/JSONCHK_H.h>
003100120130
003200120130#define true  1
003300120130#define false 0
003400120130#define __   -1     /* the universal error code */
003500120130
003600120130/*
003700120130    Characters are mapped into these 31 character classes. This allows for
003800120130    a significant reduction in the size of the state transition table.
003900120130*/
004000120130
004100120130enum classes {
004200120130    C_SPACE,  /* space */
004300120130    C_WHITE,  /* other whitespace */
004400120130    C_LCURB,  /* {  */
004500120130    C_RCURB,  /* } */
004600120130    C_LSQRB,  /* [ */
004700120130    C_RSQRB,  /* ] */
004800120130    C_COLON,  /* : */
004900120130    C_COMMA,  /* , */
005000120130    C_QUOTE,  /* " */
005100120130    C_BACKS,  /* \ */
005200120130    C_SLASH,  /* / */
005300120130    C_PLUS,   /* + */
005400120130    C_MINUS,  /* - */
005500120130    C_POINT,  /* . */
005600120130    C_ZERO ,  /* 0 */
005700120130    C_DIGIT,  /* 123456789 */
005800120130    C_LOW_A,  /* a */
005900120130    C_LOW_B,  /* b */
006000120130    C_LOW_C,  /* c */
006100120130    C_LOW_D,  /* d */
006200120130    C_LOW_E,  /* e */
006300120130    C_LOW_F,  /* f */
006400120130    C_LOW_L,  /* l */
006500120130    C_LOW_N,  /* n */
006600120130    C_LOW_R,  /* r */
006700120130    C_LOW_S,  /* s */
006800120130    C_LOW_T,  /* t */
006900120130    C_LOW_U,  /* u */
007000120130    C_ABCDF,  /* ABCDF */
007100120130    C_E,      /* E */
007200120130    C_ETC,    /* everything else */
007300120130    NR_CLASSES
007400120130};
007500120130
007600120130static int ascii_class[128] = {
007700120130/*
007800120130    This array maps the 128 ASCII characters into character classes.
007900120130    The remaining Unicode characters should be mapped to C_ETC.
008000120130    Non-whitespace control characters are errors.
008100120130*/
008200120130    __,      __,      __,      __,      __,      __,      __,      __,
008300120130    __,      C_WHITE, C_WHITE, __,      __,      C_WHITE, __,      __,
008400120130    __,      __,      __,      __,      __,      __,      __,      __,
008500120130    __,      __,      __,      __,      __,      __,      __,      __,
008600120130
008700120130    C_SPACE, C_ETC,   C_QUOTE, C_ETC,   C_ETC,   C_ETC,   C_ETC,   C_ETC,
008800120130    C_ETC,   C_ETC,   C_ETC,   C_PLUS,  C_COMMA, C_MINUS, C_POINT, C_SLASH,
008900120130    C_ZERO,  C_DIGIT, C_DIGIT, C_DIGIT, C_DIGIT, C_DIGIT, C_DIGIT, C_DIGIT,
009000120130    C_DIGIT, C_DIGIT, C_COLON, C_ETC,   C_ETC,   C_ETC,   C_ETC,   C_ETC,
009100120130
009200120130    C_ETC,   C_ABCDF, C_ABCDF, C_ABCDF, C_ABCDF, C_E,     C_ABCDF, C_ETC,
009300120130    C_ETC,   C_ETC,   C_ETC,   C_ETC,   C_ETC,   C_ETC,   C_ETC,   C_ETC,
009400120130    C_ETC,   C_ETC,   C_ETC,   C_ETC,   C_ETC,   C_ETC,   C_ETC,   C_ETC,
009500120130    C_ETC,   C_ETC,   C_ETC,   C_LSQRB, C_BACKS, C_RSQRB, C_ETC,   C_ETC,
009600120130
009700120130    C_ETC,   C_LOW_A, C_LOW_B, C_LOW_C, C_LOW_D, C_LOW_E, C_LOW_F, C_ETC,
009800120130    C_ETC,   C_ETC,   C_ETC,   C_ETC,   C_LOW_L, C_ETC,   C_LOW_N, C_ETC,
009900120130    C_ETC,   C_ETC,   C_LOW_R, C_LOW_S, C_LOW_T, C_LOW_U, C_ETC,   C_ETC,
010000120130    C_ETC,   C_ETC,   C_ETC,   C_LCURB, C_ETC,   C_RCURB, C_ETC,   C_ETC
010100120130};
010200120130
010300120130
010400120130/*
010500120130    The state codes.
010600120130*/
010700120130enum states {
010800120130    GO,  /* start    */
010900120130    OK,  /* ok       */
011000120130    OB,  /* object   */
011100120130    KE,  /* key      */
011200120130    CO,  /* colon    */
011300120130    VA,  /* value    */
011400120130    AR,  /* array    */
011500120130    ST,  /* string   */
011600120130    ES,  /* escape   */
011700120130    U1,  /* u1       */
011800120130    U2,  /* u2       */
011900120130    U3,  /* u3       */
012000120130    U4,  /* u4       */
012100120130    MI,  /* minus    */
012200120130    ZE,  /* zero     */
012300120130    IN,  /* integer  */
012400120130    FR,  /* fraction */
012500120130    E1,  /* e        */
012600120130    E2,  /* ex       */
012700120130    E3,  /* exp      */
012800120130    T1,  /* tr       */
012900120130    T2,  /* tru      */
013000120130    T3,  /* true     */
013100120130    F1,  /* fa       */
013200120130    F2,  /* fal      */
013300120130    F3,  /* fals     */
013400120130    F4,  /* false    */
013500120130    N1,  /* nu       */
013600120130    N2,  /* nul      */
013700120130    N3,  /* null     */
013800120130    NR_STATES
013900120130};
014000120130
014100120130
014200120130static int state_transition_table[NR_STATES][NR_CLASSES] = {
014300120130/*
014400120130    The state transition table takes the current state and the current symbol,
014500120130    and returns either a new state or an action. An action is represented as a
014600120130    negative number. A JSON text is accepted if at the end of the text the
014700120130    state is OK and if the mode is MODE_DONE.
014800120130
014900120130*/
015101120130 {GO,GO,-6,__,-5,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__},
015102120130 {OK,OK,__,-8,__,-7,__,-3,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__},
015103120130 {OB,OB,__,-9,__,__,__,__,ST,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__},
015104120130 {KE,KE,__,__,__,__,__,__,ST,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__},
015105120130 {CO,CO,__,__,__,__,-2,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__},
015106120130 {VA,VA,-6,__,-5,__,__,__,ST,__,__,__,MI,__,ZE,IN,__,__,__,__,__,F1,__,N1,__,__,T1,__,__,__,__},
015107120130 {AR,AR,-6,__,-5,-7,__,__,ST,__,__,__,MI,__,ZE,IN,__,__,__,__,__,F1,__,N1,__,__,T1,__,__,__,__},
015108120130 {ST,__,ST,ST,ST,ST,ST,ST,-4,ES,ST,ST,ST,ST,ST,ST,ST,ST,ST,ST,ST,ST,ST,ST,ST,ST,ST,ST,ST,ST,ST},
015109120130 {__,__,__,__,__,__,__,__,ST,ST,ST,__,__,__,__,__,__,ST,__,__,__,ST,__,ST,ST,__,ST,U1,__,__,__},
015110120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,U2,U2,U2,U2,U2,U2,U2,U2,__,__,__,__,__,__,U2,U2,__},
015111120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,U3,U3,U3,U3,U3,U3,U3,U3,__,__,__,__,__,__,U3,U3,__},
015112120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,U4,U4,U4,U4,U4,U4,U4,U4,__,__,__,__,__,__,U4,U4,__},
015113120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,ST,ST,ST,ST,ST,ST,ST,ST,__,__,__,__,__,__,ST,ST,__},
015114120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,ZE,IN,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__},
015115120130 {OK,OK,__,-8,__,-7,__,-3,__,__,__,__,__,FR,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__},
015116120130 {OK,OK,__,-8,__,-7,__,-3,__,__,__,__,__,FR,IN,IN,__,__,__,__,E1,__,__,__,__,__,__,__,__,E1,__},
015117120130 {OK,OK,__,-8,__,-7,__,-3,__,__,__,__,__,__,FR,FR,__,__,__,__,E1,__,__,__,__,__,__,__,__,E1,__},
015118120130 {__,__,__,__,__,__,__,__,__,__,__,E2,E2,__,E3,E3,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__},
015119120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,E3,E3,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__},
015120120130 {OK,OK,__,-8,__,-7,__,-3,__,__,__,__,__,__,E3,E3,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__},
015121120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,T2,__,__,__,__,__,__},
015122120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,T3,__,__,__},
015123120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,OK,__,__,__,__,__,__,__,__,__,__},
015124120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,F2,__,__,__,__,__,__,__,__,__,__,__,__,__,__},
015125120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,F3,__,__,__,__,__,__,__,__},
015126120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,F4,__,__,__,__,__},
015127120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,OK,__,__,__,__,__,__,__,__,__,__},
015128120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,N2,__,__,__},
015129120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,N3,__,__,__,__,__,__,__,__},
015130120130 {__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,__,OK,__,__,__,__,__,__,__,__},
015131120130};
018200120130
018300120130
018400120130/*
018500120130    These modes can be pushed on the stack.
018600120130*/
018700120130enum modes {
018800120130    MODE_ARRAY,
018900120130    MODE_DONE,
019000120130    MODE_KEY,
019100120130    MODE_OBJECT
019200120130};
019300120130
019400120130static int
019500120130reject(JSON_checker jc)
019600120130{
019700120130/*
019800120130    Delete the JSON_checker object.
019900120130*/
020000120130    free((void*)jc->stack);
020100120130    free((void*)jc);
020200120130    return false;
020300120130}
020400120130
020500120130
020600120130static int
020700120130push(JSON_checker jc, int mode)
020800120130{
020900120130/*
021000120130    Push a mode onto the stack. Return false if there is overflow.
021100120130*/
021200120130    jc->top += 1;
021300120130    if (jc->top >= jc->depth) {
021400120130        return false;
021500120130    }
021600120130    jc->stack[jc->top] = mode;
021700120130    return true;
021800120130}
021900120130
022000120130
022100120130static int
022200120130pop(JSON_checker jc, int mode)
022300120130{
022400120130/*
022500120130    Pop the stack, assuring that the current mode matches the expectation.
022600120130    Return false if there is underflow or if the modes mismatch.
022700120130*/
022800120130    if (jc->top < 0 || jc->stack[jc->top] != mode) {
022900120130        return false;
023000120130    }
023100120130    jc->top -= 1;
023200120130    return true;
023300120130}
023400120130
023500120130
023600120130JSON_checker
023700120130json_new_checker(int depth)
023800120130{
023900120130/*
024000120130    json_new_checker starts the checking process by constructing a JSON_checker
024100120130    object. It takes a depth parameter that restricts the level of maximum
024200120130    nesting.
024300120130
024400120130    To continue the process, call JSON_checker_char for each character in the
024500120130    JSON text, and then call JSON_checker_done to obtain the final result.
024600120130    These functions are fully reentrant.
024700120130
024800120130    The JSON_checker object will be deleted by JSON_checker_done.
024900120130    JSON_checker_char will delete the JSON_checker object if it sees an error.
025000120130*/
025100120130    JSON_checker jc = (JSON_checker)malloc(sizeof(struct json_checker_struct));
025200120130    jc->state = GO;
025300120130    jc->depth = depth;
025400120130    jc->top = -1;
025500120130    jc->stack = (int*)calloc(depth, sizeof(int));
025600120130    push(jc, MODE_DONE);
025700120130    return jc;
025800120130}
025900120130
026000120130
026100120130int
026200120130json_checker_char(JSON_checker jc, int next_char)
026300120130{
026400120130/*
026500120130    After calling new_JSON_checker, call this function for each character (or
026600120130    partial character) in your JSON text. It can accept UTF-8, UTF-16, or
026700120130    UTF-32. It returns true if things are looking ok so far. If it rejects the
026800120130    text, it deletes the JSON_checker object and returns false.
026900120130*/
027000120130    int next_class, next_state;
027100120130/*
027200120130    Determine the character's class.
027300120130*/
027400120130    if (next_char < 0) {
027500120130        return reject(jc);
027600120130    }
027700120130    if (next_char >= 128) {
027800120130        next_class = C_ETC;
027900120130    } else {
028000120130        next_class = ascii_class[next_char];
028100120130        if (next_class <= __) {
028200120130            return reject(jc);
028300120130        }
028400120130    }
028500120130/*
028600120130    Get the next state from the state transition table.
028700120130*/
028800120130    next_state = state_transition_table[jc->state][next_class];
028900120130    if (next_state >= 0) {
029000120130/*
029100120130    Change the state.
029200120130*/
029300120130        jc->state = next_state;
029400120130    } else {
029500120130/*
029600120130    Or perform one of the actions.
029700120130*/
029800120130        switch (next_state) {
029900120130/* empty } */
030000120130        case -9:
030100120130            if (!pop(jc, MODE_KEY)) {
030200120130                return reject(jc);
030300120130            }
030400120130            jc->state = OK;
030500120130            break;
030600120130
030700120130/* } */ case -8:
030800120130            if (!pop(jc, MODE_OBJECT)) {
030900120130                return reject(jc);
031000120130            }
031100120130            jc->state = OK;
031200120130            break;
031300120130
031400120130/* ] */ case -7:
031500120130            if (!pop(jc, MODE_ARRAY)) {
031600120130                return reject(jc);
031700120130            }
031800120130            jc->state = OK;
031900120130            break;
032000120130
032100120130/* { */ case -6:
032200120130            if (!push(jc, MODE_KEY)) {
032300120130                return reject(jc);
032400120130            }
032500120130            jc->state = OB;
032600120130            break;
032700120130
032800120130/* [ */ case -5:
032900120130            if (!push(jc, MODE_ARRAY)) {
033000120130                return reject(jc);
033100120130            }
033200120130            jc->state = AR;
033300120130            break;
033400120130
033500120130/* " */ case -4:
033600120130            switch (jc->stack[jc->top]) {
033700120130            case MODE_KEY:
033800120130                jc->state = CO;
033900120130                break;
034000120130            case MODE_ARRAY:
034100120130            case MODE_OBJECT:
034200120130                jc->state = OK;
034300120130                break;
034400120130            default:
034500120130                return reject(jc);
034600120130            }
034700120130            break;
034800120130
034900120130/* , */ case -3:
035000120130            switch (jc->stack[jc->top]) {
035100120130            case MODE_OBJECT:
035200120130/*
035300120130    A comma causes a flip from object mode to key mode.
035400120130*/
035500120130                if (!pop(jc, MODE_OBJECT) || !push(jc, MODE_KEY)) {
035600120130                    return reject(jc);
035700120130                }
035800120130                jc->state = KE;
035900120130                break;
036000120130            case MODE_ARRAY:
036100120130                jc->state = VA;
036200120130                break;
036300120130            default:
036400120130                return reject(jc);
036500120130            }
036600120130            break;
036700120130
036800120130/* : */ case -2:
036900120130/*
037000120130    A colon causes a flip from key mode to object mode.
037100120130*/
037200120130            if (!pop(jc, MODE_KEY) || !push(jc, MODE_OBJECT)) {
037300120130                return reject(jc);
037400120130            }
037500120130            jc->state = VA;
037600120130            break;
037700120130/*
037800120130    Bad action.
037900120130*/
038000120130        default:
038100120130            return reject(jc);
038200120130        }
038300120130    }
038400120130    return true;
038500120130}
038600120130
038700120130
038800120130int
038900120130json_checker_done(JSON_checker jc)
039000120130{
039100120130/*
039200120130    The JSON_checker_done function should be called after all of the characters
039300120130    have been processed, but only if every call to JSON_checker_char returned
039400120130    true. This function deletes the JSON_checker and returns true if the JSON
039500120130    text was accepted.
039600120130*/
039700120130    int result = jc->state == OK && pop(jc, MODE_DONE);
039800120130    reject(jc);
039900120130    return result;
040000120130}
