#!/usr/bin/python3

# Things to think about
#
# - How should we handle cases where only two symbols are used? (synonym vs final)
# - Should we introduce an error state or use the final state if a cell is not filled?

import argparse
import logging


# Initialise logger
logging.basicConfig()
logger = logging.getLogger("turing")

all_states = []
all_signs = []
FINAL_STATE_NAME = "FINAL"
# We set 8 backup symbols in case some are already in use
BACKUP_SYMBOLS = {"0", "1", "2", "B",
                  "A", "B", "C", "#"}

""" on_status on_sign direction new_sign new_state """

def read_file(filename: str) -> str:
    with open(filename, "r") as file:
        return file.readlines()


def parse(lines):
    commands = {}

    for line in lines:
        # Ignore whitespace and comments
        line = line.strip()
        if line == "" or line.startswith("#"):
            continue

        # Load the tokens on the line
        tokens = line.split(" ")
        on_state = tokens[0]
        on_sign = tokens[1]
        direction = tokens[2]
        sign = tokens[3]
        state = tokens[4]

        if on_state == FINAL_STATE_NAME:
            logger.error("You are not allowed to define the `FINAL` state as it is reserved for program!")
            exit()

        append_if_not_in_list(on_state, all_states)
        append_if_not_in_list(on_sign, all_signs)

        if state != FINAL_STATE_NAME:
            append_if_not_in_list(state, all_states)
        append_if_not_in_list(sign, all_signs)

        if on_state not in commands.keys():
            commands[on_state] = {}

        if state != FINAL_STATE_NAME:
            commands[on_state][on_sign] = (get_direction_bit(direction), all_signs.index(sign), all_states.index(state))
        else:
            commands[on_state][on_sign] = (get_direction_bit(direction), all_signs.index(sign), 31)

    if len(all_states) > 19:
        logger.error("Too many states are used!")
        exit()
    elif len(all_signs) > 4:
        logger.error("Too many signs are used! The 8051 simulator only supports 2 Bits = 4 signs.")
        exit()
    else:
        return commands


def sort_commands(commands):
    # In order to fill out the entire 4 columns, add backup symbols
    while len(all_signs) < 4:
        all_signs.append(-1)

    out = []
    for state in all_states:
        for sign in all_signs:
            if sign in commands[state].keys():
                out.append(commands[state][sign])
            else:
                out.append([1, 3, 31])

    return out


def get_direction_bit(direction):
    if direction == '<':
        return 0
    if direction == '>':
        return 1


def append_if_not_in_list(object_, list_):
    if object_ not in list_:
        list_.append(object_)


def stringify(sorted_out_list):
    string = ""

    counter = 0
    for entry in sorted_out_list:

        string += "{}\t".format(counter * 1000)
        string += str(entry[0])
        string += "{0:02b}".format(entry[1]).replace("", " ")[:-1]
        string += "{0:05b}".format(entry[2]).replace("", " ")[:-1]
        string += "\n"

        counter += 8

    return string


if __name__ == "__main__":
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Simple Turing Compiler for our 8051 University project")
    parser.add_argument(
        "program",
        type=str,
        help="The input program that shall be compiled")
    parser.add_argument(
        "--out",
        type=str,
        default=None,
        help="The output file of the compiled program")
    parser.add_argument(
        "--debug",
        type=bool,
        default=False,
        help="Whether to output debugging information")
    args = parser.parse_args()

    # Set output level
    if args.debug:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.WARNING)

    lines = read_file(args.program)

    # Parse
    result = parse(lines)
    sorted_commands = sort_commands(result)

    # Print debugging output
    logger.debug("All signs: " + str(all_signs))
    logger.debug("All states: " + str(all_states))
    logger.debug("Length of sorted commands: " + str(len(sorted_commands)))

    output = stringify(sorted_commands)
    if args.out is None:
        logger.info(f"Compiler output:\n{output}")
    else:
        with open(args.out, "w") as f:
            f.write(output)
            logger.info("Wrote compiler output to file.")
