import ReactNative from 'react-native';
import React from 'react';

const {
  View,
  Text,
  Slider,
  AppRegistry,
} = ReactNative;

// eslint-disable-next-line
const RCTDeviceEventEmitter = require('RCTDeviceEventEmitter');
const metadata = require('./app.json')

class App extends React.Component {
  constructor() {
    super();
    this.state = {
      metadataTree: metadata
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
          return React.createElement(Slider, { style: tree.style, props: tree.props });
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


}

AppRegistry.registerComponent('SpikeIOSSimulator', () => App);
