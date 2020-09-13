from textwrap import TextWrapper


class DocumentWrapper(TextWrapper):

    def wrap(self, text):
        split_text = text.split('\n')
        wrapped_lines = []
        for line in split_text:
            if line == '':
                wrapped_lines.append(line)
                continue
            wrapped_lines.extend(TextWrapper.wrap(self, line))

        return '       \n'.join(wrapped_lines) + '       '
