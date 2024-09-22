import abilityTest from './Ability.test';
import MenuTest from './Menu.test';
import NewsTest from './News.test';

export default function testsuite() {
  abilityTest();
  NewsTest();
  MenuTest();
}