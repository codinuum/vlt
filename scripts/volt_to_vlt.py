#!/usr/bin/env python3

'''
  volt_to_vlt.py

  Copyright 2025 Codinuum Software Lab <codinuum@me.com>

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
'''

__author__ = 'Codinuum <codinuum@me.com>'

from collections import deque
import logging

logger = logging.getLogger()

LOGGING_FORMAT = '[%(asctime)s][%(levelname)s][%(module)s][%(funcName)s] %(message)s'

SPACE_LIST = [' ', '\t']
PUNC_LIST = ['(', ')', ';', ',', '\n', '*']
HEAD_CONV_TBL = {
    'DEBUG_MSG': '[%debug_log',
    'FATAL_MSG': '[%fatal_log',
    'INFO_MSG': '[%info_log',
    'WARN_MSG': '[%warn_log',
    'ERROR_MSG': '[%error_log',
    'TRACE_MSG': '[%trace_log',
}
CONV_TBL = {
    'BEGIN_DEBUG': 'begin %debug_block',
    'BEGIN_FATAL': 'begin %fatal_block',
    'BEGIN_INFO': 'begin %info_block',
    'BEGIN_WARN': 'begin %warn_block',
    'BEGIN_ERROR': 'begin %error_block',
    'BEGIN_TRACE': 'begin %trace_block',
    'END_DEBUG': 'end',
    'END_FATAL': 'end',
    'END_INFO': 'end',
    'END_WARN': 'end',
    'END_ERROR': 'end',
    'END_TRACE': 'end',
}


def is_space(x):
    b = x in SPACE_LIST
    return b


def is_punc(x):
    b = x in PUNC_LIST
    return b


def count_percs_in_string(s):
    count = 0
    prev = None
    for c in s:
        if c == '%':
            if prev == '%':
                count -= 1
            else:
                count += 1
        elif c == 'a' and prev == '%':
            count += 1
        prev = c
    logger.debug(f'count={count} s={s!r}')
    return count


def count_percs_in_expr(s, next_token, token_list):
    count = 0
    plv = 1
    while True:
        token = next_token()

        if token.startswith('"'):
            count += count_percs_in_string(token)

        elif token == ')':
            plv -= 1

        elif token == '(':
            plv += 1

        token_list.append(token)

        if plv <= 0:
            break

    return count


def tokenize(s):
    tl = []
    word = ''
    string = ''
    str_flag = False
    prev = None
    for c in s:
        ssize = len(string)
        if c == '"' and (prev != '\\' or ssize > 1 and string[-2] == '\\'
                         and (ssize < 3 or string[-3] != '\\')):
            if str_flag:  # end of string
                logger.debug(f'end of string: string="{string}"')
                string += c
                tl.append(string)
                string = ''
                str_flag = False

            elif prev == "'":
                word += c

            else:  # head of string
                logger.debug(f'head of string: word="{word}"')
                if word != '':
                    tl.append(word)
                    word = ''
                str_flag = True
                string += c

        elif str_flag:
            # logger.debug(f'c="{c}"')
            string += c

        elif c == '>' and prev == '-' and word == '-':
            word += c
            tl.append(word)
            word = ''

        elif c == '(' and prev == '.':
            word += c
            tl.append(word)
            word = ''

        elif c == '#' and prev == ')' and word == '':
            word = tl.pop()
            word += c

        elif is_punc(c):
            if word != '':
                tl.append(word)
                word = ''
            tl.append(c)

        elif is_space(c):
            if is_space(prev):
                word += c
            else:
                if word != '':
                    tl.append(word)
                word = c
        else:
            if is_space(prev):
                if word != '':
                    tl.append(word)
                word = c
            else:
                word += c

        prev = c

    if word != '':
        tl.append(word)

    return tl


class Empty(Exception):
    pass


def skip_and_insert(count, next_token, token_list):
    logger.debug(f'count={count}')
    skip_count = 0
    plv = 0
    while True:
        token = next_token()

        if plv > 0:
            if token.startswith(')'):
                plv -= 1
                if plv == 0:
                    skip_count += 1
                    # logger.debug(f'skip_count -> {skip_count}')

            elif token.endswith('('):
                plv += 1

        elif token.endswith('('):
            plv += 1

        elif is_space(token[0]) or token == '\n':
            pass

        else:
            skip_count += 1
            # logger.debug(f'skip_count -> {skip_count}')

        token_list.append(token)

        if skip_count >= count:
            logger.debug(f'inserting "]": {token_list}')
            token_list.append(']')
            break


def scan(enqueue, put_line):
    queue = deque()
    enqueue(queue)

    def next_token():
        if len(queue) == 0:
            enqueue(queue)
        if len(queue) == 0:
            raise Empty
        token = queue.popleft()
        # logger.debug(f'token={token!r}')
        return token

    flag = False
    tl_ = []

    try:
        while True:
            token = next_token()

            if flag:
                if token.startswith('"'):
                    count = count_percs_in_string(token)
                    tl_.append(token)
                    if count == 0:
                        logger.debug(f'inserting "]": {tl_}')
                        tl_.append(']')
                        flag = False
                    else:
                        skip_and_insert(count, next_token, tl_)
                        flag = False

                elif token == '(':
                    tl_.append(token)
                    count = count_percs_in_expr(token, next_token, tl_)
                    if count == 0:
                        logger.debug(f'inserting "]": {tl_}')
                        tl_.append(']')
                        flag = False
                    else:
                        skip_and_insert(count, next_token, tl_)
                        flag = False

                elif is_space(token[0]):
                    tl_.append(token)

            elif token in HEAD_CONV_TBL:
                flag = True
                tl_.append(HEAD_CONV_TBL[token])

            elif token == '\n':
                tl_.append(token)
                line = ''.join(tl_)
                put_line(line)
                tl_ = []

            elif token in CONV_TBL:
                tl_.append(CONV_TBL[token])

            else:
                tl_.append(token)

    except Empty:
        logger.debug('queue empty!')
        pass


def conv(in_file, out_file):
    with open(in_file, 'r') as in_f:
        with open(out_file, 'w') as out_f:

            def enqueue(q):
                # logger.debug(f'len(q)={len(q)}')
                line = in_f.readline()
                while line.endswith('\\\n'):
                    line += in_f.readline()
                if line:
                    tl = tokenize(line)
                    logger.debug(f'tl={tl}')
                    q.extend(tl)

            def put_line(x):
                out_f.write(x)

            scan(enqueue, put_line)


if __name__ == '__main__':
    from argparse import ArgumentParser, ArgumentDefaultsHelpFormatter

    parser = ArgumentParser(description='convert volt directives into vlt directives',
                            formatter_class=ArgumentDefaultsHelpFormatter)

    parser.add_argument('in_file', help='source file')

    parser.add_argument('-d', '--debug', dest='debug', action='store_true',
                        help='enable debug printing')

    parser.add_argument('-o', '--out-file', dest='out_file', default='a.ml',
                        help='specify target file')

    args = parser.parse_args()

    log_level = logging.INFO
    if args.debug:
        log_level = logging.DEBUG
    log_file = 'volt_to_vlt.log'
    logging.basicConfig(format=LOGGING_FORMAT, filename=log_file, filemode='w',
                        level=log_level)

    conv(args.in_file, args.out_file)
