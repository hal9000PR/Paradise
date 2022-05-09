import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Flex, Icon, Section, Slider } from '../components';
import { Window } from '../layouts';

export const Testing = (properties, context) => {
  const { act, data } = useBackend(context);
  const {
    matrix,
  } = data;
  return (
    <Window>
      <Window.Content>
        <Section height="100%" overflow="auto">
          {matrix.map(channel => (
            <Fragment key={channel.num}>
              <Box fontSize="1.25rem" color="label">{channel.num}</Box>
              <Box mt="0.5rem">
                <Flex>
                  <Flex.Item>
                    <Button width="24px" color="transparent">
                      <Icon
                        name="volume-off"
                        size="1.5"
                        mt="0.1rem"
                        onClick={() => act("volume", { channel: channel.num, volume: 0 })}
                      />
                    </Button>
                  </Flex.Item>
                  <Flex.Item grow="1" mx="1rem">
                    <Slider
                      minValue={-1.5}
                      maxValue={1.5}
                      step={0.05}
                      stepPixelSize={20}
                      value={channel.value}
                      onChange={(e, value) => act("volume", { channel: channel.num, volume: value })}
                    />
                  </Flex.Item>
                  <Flex.Item>
                    <Button width="24px" color="transparent">
                      <Icon
                        name="volume-up"
                        size="1.5"
                        mt="0.1rem"
                        onClick={() => act("volume", { channel: channel.num, volume: 1.5 })}
                      />
                    </Button>
                  </Flex.Item>
                </Flex>
              </Box>
            </Fragment>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
