import ReactNative from 'react-native-desktop';
import React from 'react';

const { View, Text, SliderIOS, AppRegistry } = ReactNative;

// eslint-disable-next-line
const RCTDeviceEventEmitter = require('RCTDeviceEventEmitter');

class App extends React.Component {
  constructor() {
    super();
    this.state = {
      metadataTree: {
        type: 'View',
        style: {
          flex: 1,
          backgroundColor: 'white',
          justifyContent: 'center',
          alignItems: 'center',
        },
        props: {
          children: [
            {
              type: 'Text',
              style: {
                color: '#444',
                fontSize: 18,
              },
              props: {
                value: 'Press CMD+Enter to execute',
              },
            },
          ],
        },
      },
    };
  }

  componentDidMount() {
    RCTDeviceEventEmitter.addListener(
        'onCommit',
        e => {
          // prevent to fail
          const filtered = e.metadata.replace(/\s+/g, ' ').replace(/\n/g, '').replace(/\t/g, '');
          try {
            this.setState({ metadataTree: JSON.parse(filtered) });
          } catch (ex) { console.log(ex); }
        }
    );
  }

  buildTree(tree) {
    if (tree && tree.type) {
      switch (tree.type) {
        case 'View': {
          const children = tree.props && tree.props.children &&
            tree.props.children.map(child => this.buildTree(child));
          return React.createElement(View, { style: tree.style, children });
        }
        case 'Text': {
          const children = tree.props.value ? tree.props.value
            : tree.props && tree.props.children &&
              tree.props.children.map(child => this.buildTree(child));
          return React.createElement(Text, {
            ...tree.props,
            style: tree.style,
            children,
          });
        }
        case 'Slider': {
          return React.createElement(SliderIOS, { style: tree.style, props: tree.props });
        }
        case 'Switch': {
          return React.createElement(View, {
            style: tree.style,
            children: [
              this.buildTree({ type: 'Text', props: { value: '<SwitchIOS>' } }),
            ],
          });
        }
        default:
          console.log(`${tree.type} is not implemented yet`);
          break;
      }
    }
    return null;
  }

  render() {
    return this.buildTree(this.state.metadataTree);
  }

  renderPlayground() {
    return (
      <View style={{ flex: 1 }}>
        <Text>playground</Text>
      </View>
    );
  }


}

AppRegistry.registerComponent('SpikeRND', () => App);
